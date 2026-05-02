# Option list para versoes suportadas de Kubernetes
# Pode ser substituido por uma lista REST consultando uma API de versoes externas.
resource "hpe_morpheus_option_list_manual" "k8s_versions" {
  name        = "${var.workflow_name}-k8s-versions"
  description = "Kubernetes versions available for kubeadm install"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "v1.32", value = "v1.32.0" },
    { name = "v1.31", value = "v1.31.0" },
    { name = "v1.30", value = "v1.30.0" },
    { name = "v1.29", value = "v1.29.0" },
  ])
}

# Perfis de add-ons para simplificar combinacoes no formulario.
resource "hpe_morpheus_option_list_manual" "addon_profiles" {
  name        = "${var.workflow_name}-addon-profiles"
  description = "Recommended add-on profiles for Kubernetes clusters"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "Minimal", value = "minimal" },
    { name = "Standard Platform", value = "standard" },
    { name = "Enterprise Platform", value = "enterprise" },
  ])
}

# CNIs suportados pelo workflow kubeadm.
resource "hpe_morpheus_option_list_manual" "cni_addons" {
  name        = "${var.workflow_name}-cni-addons"
  description = "Container Network Interface options"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "Flannel", value = "flannel" },
    { name = "Calico", value = "calico" },
  ])
}

# CSI drivers genericos para ambientes com VMs existentes.
resource "hpe_morpheus_option_list_manual" "csi_addons" {
  name        = "${var.workflow_name}-csi-addons"
  description = "Container Storage Interface options"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "None", value = "none" },
    { name = "Local Path Provisioner", value = "local-path-provisioner" },
  ])
}

# Controladores de entrada suportados.
resource "hpe_morpheus_option_list_manual" "ingress_addons" {
  name        = "${var.workflow_name}-ingress-addons"
  description = "Ingress controller options"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "None", value = "none" },
    { name = "ingress-nginx", value = "ingress-nginx" },
  ])
}

# Stack de observabilidade opcionais.
resource "hpe_morpheus_option_list_manual" "observability_addons" {
  name        = "${var.workflow_name}-observability-addons"
  description = "Observability add-ons for the cluster"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "metrics-server", value = "metrics-server" },
  ])
}

# Add-ons de seguranca e gestao de segredos.
resource "hpe_morpheus_option_list_manual" "security_addons" {
  name        = "${var.workflow_name}-security-addons"
  description = "Security and secret management add-ons"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "cert-manager", value = "cert-manager" },
    { name = "Sealed Secrets", value = "sealed-secrets" },
    { name = "Kyverno", value = "kyverno" },
  ])
}

# Ferramentas GitOps opcionais.
resource "hpe_morpheus_option_list_manual" "gitops_addons" {
  name        = "${var.workflow_name}-gitops-addons"
  description = "GitOps add-ons for continuous delivery"
  labels      = var.workflow_labels
  real_time   = false

  dataset = jsonencode([
    { name = "Argo CD", value = "argocd" },
  ])
}
