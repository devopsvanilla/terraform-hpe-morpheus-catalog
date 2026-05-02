# Task 0 — Pre-requisitos do host (swap, modulos kernel, sysctl)
# Executa em TODOS os nos selecionados (control plane + workers).
# No workflow o alvo sera configurado para cada grupo de VMs.
resource "hpe_morpheus_task_shell_script" "prereqs" {
  name                = "${var.workflow_name}-00-prereqs"
  code                = "${var.workflow_name}-00-prereqs"
  labels              = var.workflow_labels
  source_type         = "local"
  execute_target      = "resource"
  result_type         = "value"
  sudo                = true
  retryable           = false
  allow_custom_config = true

  # Nota: $${VAR} em heredoc Terraform gera ${VAR} no script final (bash).
  # Nested heredocs usam delimitadores distintos para evitar conflito com Terraform.
  script_content = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    swapoff -a
    sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
    printf 'overlay\nbr_netfilter\n' > /etc/modules-load.d/k8s.conf
    modprobe overlay
    modprobe br_netfilter
    printf 'net.bridge.bridge-nf-call-iptables=1\nnet.bridge.bridge-nf-call-ip6tables=1\nnet.ipv4.ip_forward=1\n' > /etc/sysctl.d/k8s.conf
    sysctl --system
    echo "prereqs_ok=true"
  SCRIPT
}

# Task 1 — kubeadm init no primeiro control plane
# Recebe: k8s_version, cluster_name, pod_network_cidr do formulario (Morpheus <%=...%>).
# Emite JSON com join_command e certificate_key para as tasks seguintes.
resource "hpe_morpheus_task_shell_script" "control_plane_init" {
  name                = "${var.workflow_name}-01-control-plane-init"
  code                = "${var.workflow_name}-01-control-plane-init"
  labels              = var.workflow_labels
  source_type         = "local"
  execute_target      = "resource"
  result_type         = "json"
  sudo                = true
  retryable           = false
  allow_custom_config = true

  script_content = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    K8S_VERSION="<%=customOptions.k8s_version%>"
    CLUSTER_NAME="<%=customOptions.cluster_name%>"
    POD_NETWORK_CIDR="<%=customOptions.pod_network_cidr%>"
    kubeadm init \
      --kubernetes-version "$${K8S_VERSION}" \
      --cluster-name "$${CLUSTER_NAME}" \
      --pod-network-cidr "$${POD_NETWORK_CIDR}" \
      --upload-certs 2>&1
    mkdir -p /root/.kube
    cp /etc/kubernetes/admin.conf /root/.kube/config
    chmod 600 /root/.kube/config /etc/kubernetes/admin.conf
    JOIN_CMD=$$(kubeadm token create --print-join-command)
    CERT_KEY=$$(kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n1)
    printf '{"join_command":"%s","certificate_key":"%s"}' "$${JOIN_CMD}" "$${CERT_KEY}"
  SCRIPT
}

# Task 2 — Join dos control planes secundarios
# Recebe join_command e certificate_key via Morpheus result reference.
resource "hpe_morpheus_task_shell_script" "control_plane_join" {
  name                = "${var.workflow_name}-02-control-plane-join"
  code                = "${var.workflow_name}-02-control-plane-join"
  labels              = var.workflow_labels
  source_type         = "local"
  execute_target      = "resource"
  result_type         = "value"
  sudo                = true
  retryable           = true
  retry_count         = 2
  retry_delay_seconds = 30
  allow_custom_config = true

  script_content = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    JOIN_CMD="<%=results['${var.workflow_name}-01-control-plane-init'].join_command%>"
    CERT_KEY="<%=results['${var.workflow_name}-01-control-plane-init'].certificate_key%>"
    $${JOIN_CMD} --control-plane --certificate-key "$${CERT_KEY}"
  SCRIPT
}

# Task 3 — Join dos worker nodes
# Recebe join_command via Morpheus result reference da task 01.
resource "hpe_morpheus_task_shell_script" "worker_join" {
  name                = "${var.workflow_name}-03-worker-join"
  code                = "${var.workflow_name}-03-worker-join"
  labels              = var.workflow_labels
  source_type         = "local"
  execute_target      = "resource"
  result_type         = "value"
  sudo                = true
  retryable           = true
  retry_count         = 2
  retry_delay_seconds = 30
  allow_custom_config = true

  script_content = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    JOIN_CMD="<%=results['${var.workflow_name}-01-control-plane-init'].join_command%>"
    $${JOIN_CMD}
  SCRIPT
}

# Task 4 — Instalacao dos add-ons do cluster no primeiro control plane.
# Executa manifests curados usando as escolhas do formulario.
resource "hpe_morpheus_task_shell_script" "platform_addons" {
  name                = "${var.workflow_name}-04-platform-addons"
  code                = "${var.workflow_name}-04-platform-addons"
  labels              = var.workflow_labels
  source_type         = "local"
  execute_target      = "resource"
  result_type         = "value"
  sudo                = true
  retryable           = true
  retry_count         = 2
  retry_delay_seconds = 30
  allow_custom_config = true

  script_content = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail

    CNI_ADDON="<%=customOptions.cni_addon%>"
    CSI_ADDON="<%=customOptions.csi_addon%>"
    INGRESS_ADDON="<%=customOptions.ingress_addon%>"
    OBSERVABILITY_ADDONS="<%=customOptions.observability_addons%>"
    SECURITY_ADDONS="<%=customOptions.security_addons%>"
    GITOPS_ADDONS="<%=customOptions.gitops_addons%>"

    export KUBECONFIG=/etc/kubernetes/admin.conf

    normalize_list() {
      printf '%s' "$${1}" | tr ';' ',' | tr -d '[]" ' | sed 's/,,*/,/g; s/^,//; s/,$//'
    }

    has_selection() {
      local list="$${1}"
      local item="$${2}"
      [[ ",$${list}," == *",$${item},"* ]]
    }

    apply_manifest() {
      local name="$${1}"
      local url="$${2}"
      echo "Installing $${name} from $${url}"
      kubectl apply -f "$${url}"
    }

    OBSERVABILITY_ADDONS=$$(normalize_list "$${OBSERVABILITY_ADDONS}")
    SECURITY_ADDONS=$$(normalize_list "$${SECURITY_ADDONS}")
    GITOPS_ADDONS=$$(normalize_list "$${GITOPS_ADDONS}")

    case "$${CNI_ADDON}" in
      flannel)
        apply_manifest "flannel" "https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"
        ;;
      calico)
        apply_manifest "calico" "https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml"
        ;;
      *)
        echo "Unsupported CNI add-on: $${CNI_ADDON}" >&2
        exit 1
        ;;
    esac

    case "$${CSI_ADDON}" in
      none|"")
        echo "Skipping CSI installation"
        ;;
      local-path-provisioner)
        apply_manifest "local-path-provisioner" "https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml"
        ;;
      *)
        echo "Unsupported CSI add-on: $${CSI_ADDON}" >&2
        exit 1
        ;;
    esac

    case "$${INGRESS_ADDON}" in
      none|"")
        echo "Skipping ingress controller installation"
        ;;
      ingress-nginx)
        apply_manifest "ingress-nginx" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/baremetal/deploy.yaml"
        ;;
      *)
        echo "Unsupported ingress add-on: $${INGRESS_ADDON}" >&2
        exit 1
        ;;
    esac

    if has_selection "$${OBSERVABILITY_ADDONS}" "metrics-server"; then
      apply_manifest "metrics-server" "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    fi

    if has_selection "$${SECURITY_ADDONS}" "cert-manager"; then
      apply_manifest "cert-manager" "https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.yaml"
    fi

    if has_selection "$${SECURITY_ADDONS}" "sealed-secrets"; then
      apply_manifest "sealed-secrets" "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.28.0/controller.yaml"
    fi

    if has_selection "$${SECURITY_ADDONS}" "kyverno"; then
      apply_manifest "kyverno" "https://github.com/kyverno/kyverno/releases/download/v1.14.0/install.yaml"
    fi

    if has_selection "$${GITOPS_ADDONS}" "argocd"; then
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
      apply_manifest "argocd" "https://raw.githubusercontent.com/argoproj/argo-cd/v2.14.9/manifests/install.yaml"
    fi

    echo "addons_installed=true"
  SCRIPT
}
