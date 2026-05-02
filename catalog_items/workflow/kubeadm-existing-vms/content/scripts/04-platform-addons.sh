#!/usr/bin/env bash
set -euo pipefail

# Expected runtime variables:
# CNI_ADDON
# CSI_ADDON
# INGRESS_ADDON
# OBSERVABILITY_ADDONS (comma-separated)
# SECURITY_ADDONS (comma-separated)
# GITOPS_ADDONS (comma-separated)

: "${CNI_ADDON:?CNI_ADDON is required}"
: "${CSI_ADDON:=none}"
: "${INGRESS_ADDON:=none}"
: "${OBSERVABILITY_ADDONS:=}"
: "${SECURITY_ADDONS:=}"
: "${GITOPS_ADDONS:=}"

export KUBECONFIG=/etc/kubernetes/admin.conf

normalize_list() {
  printf '%s' "$1" | tr ';' ',' | tr -d '[]" ' | sed 's/,,*/,/g; s/^,//; s/,$//'
}

has_selection() {
  local list="$1"
  local item="$2"
  [[ ",$list," == *",$item,"* ]]
}

apply_manifest() {
  local name="$1"
  local url="$2"
  echo "Installing ${name} from ${url}"
  kubectl apply -f "${url}"
}

OBSERVABILITY_ADDONS="$(normalize_list "${OBSERVABILITY_ADDONS}")"
SECURITY_ADDONS="$(normalize_list "${SECURITY_ADDONS}")"
GITOPS_ADDONS="$(normalize_list "${GITOPS_ADDONS}")"

case "${CNI_ADDON}" in
  flannel)
    apply_manifest "flannel" "https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"
    ;;
  calico)
    apply_manifest "calico" "https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml"
    ;;
  *)
    echo "Unsupported CNI add-on: ${CNI_ADDON}" >&2
    exit 1
    ;;
esac

case "${CSI_ADDON}" in
  none|"")
    echo "Skipping CSI installation"
    ;;
  local-path-provisioner)
    apply_manifest "local-path-provisioner" "https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml"
    ;;
  *)
    echo "Unsupported CSI add-on: ${CSI_ADDON}" >&2
    exit 1
    ;;
esac

case "${INGRESS_ADDON}" in
  none|"")
    echo "Skipping ingress controller installation"
    ;;
  ingress-nginx)
    apply_manifest "ingress-nginx" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/baremetal/deploy.yaml"
    ;;
  *)
    echo "Unsupported ingress add-on: ${INGRESS_ADDON}" >&2
    exit 1
    ;;
esac

if has_selection "${OBSERVABILITY_ADDONS}" "metrics-server"; then
  apply_manifest "metrics-server" "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
fi

if has_selection "${SECURITY_ADDONS}" "cert-manager"; then
  apply_manifest "cert-manager" "https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.yaml"
fi

if has_selection "${SECURITY_ADDONS}" "sealed-secrets"; then
  apply_manifest "sealed-secrets" "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.28.0/controller.yaml"
fi

if has_selection "${SECURITY_ADDONS}" "kyverno"; then
  apply_manifest "kyverno" "https://github.com/kyverno/kyverno/releases/download/v1.14.0/install.yaml"
fi

if has_selection "${GITOPS_ADDONS}" "argocd"; then
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
  apply_manifest "argocd" "https://raw.githubusercontent.com/argoproj/argo-cd/v2.14.9/manifests/install.yaml"
fi