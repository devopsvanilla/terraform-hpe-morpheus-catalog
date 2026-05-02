# Formulario de requisicao com seletores em cascata:
#   group → cloud (filtrada pelo grupo) → VMs (filtradas pelo cloud)
#
# Ordem de preenchimento pelo usuario:
#   1. Grupo Morpheus
#   2. Cloud (filtrada pelo grupo selecionado)
#   3. Versao do Kubernetes
#   4. Nome do Cluster
#   5. VMs do Control Plane (filtradas pelo cloud)
#   6. VMs dos Worker Nodes (filtradas pelo cloud)
#   7. Pod Network CIDR (opcional)
#   8. Perfil de Add-ons
#   9. CNI
#  10. CSI
#  11. Ingress Controller
#  12. Observability Add-ons
#  13. Security Add-ons
#  14. GitOps Add-ons
resource "hpe_morpheus_form" "kubeadm_request" {
  name        = "${var.workflow_name}-request-form"
  code        = "${var.workflow_name}-request-form"
  description = "Request form for kubeadm cluster installation on existing VMs"
  labels      = var.workflow_labels

  # Campo 1 — Grupo Morpheus
  # Filtra quais clouds aparecem no campo seguinte.
  option_type {
    name        = "${var.workflow_name}-group"
    code        = "${var.workflow_name}-group"
    description = "Morpheus group containing the target VMs"
    type        = "group"
    field_label = "Group"
    field_name  = "group"
    required    = true
    help_block  = "Select the Morpheus group. The cloud selector will show only clouds within this group."
  }

  # Campo 2 — Cloud Morpheus (filtrado pelo grupo)
  # Filtra quais VMs aparecem nos campos servers-input abaixo.
  option_type {
    name             = "${var.workflow_name}-cloud"
    code             = "${var.workflow_name}-cloud"
    description      = "Morpheus cloud where the target VMs are registered"
    type             = "cloud"
    field_label      = "Cloud"
    field_name       = "cloud"
    required         = true
    group_field_type = "field"
    group_field      = "group"
    help_block       = "Select the cloud. VM selectors below will show only servers registered in this cloud."
  }

  # Campo 3 — Versao do Kubernetes (select ligado a option list)
  option_type {
    name           = "${var.workflow_name}-k8s-version"
    code           = "${var.workflow_name}-k8s-version"
    description    = "Kubernetes version to install with kubeadm"
    type           = "select"
    field_label    = "Kubernetes Version"
    field_name     = "k8s_version"
    required       = true
    option_list_id = hpe_morpheus_option_list_manual.k8s_versions.id
    help_block     = "Ensure kubeadm on target VMs supports the selected version."
  }

  # Campo 4 — Nome do Cluster
  option_type {
    name        = "${var.workflow_name}-cluster-name"
    code        = "${var.workflow_name}-cluster-name"
    description = "Name for the Kubernetes cluster"
    type        = "text"
    field_label = "Cluster Name"
    field_name  = "cluster_name"
    required    = true
    help_block  = "Lowercase alphanumeric and hyphens only."
  }

  # Campo 5 — VMs do Control Plane (multi-select dinamico filtrado pelo cloud)
  # Exibe servidores registrados no cloud selecionado no campo 2.
  option_type {
    name             = "${var.workflow_name}-control-plane-vms"
    code             = "${var.workflow_name}-control-plane-vms"
    description      = "VMs to use as Kubernetes control plane nodes"
    type             = "servers-input"
    field_label      = "Control Plane VMs"
    field_name       = "control_plane_vms"
    required         = true
    cloud_field_type = "field"
    cloud_field      = "cloud"
    help_block       = "Select 1 or 3 VMs for control plane. Minimum: 2 vCPU, 2 GB RAM, Linux."
  }

  # Campo 6 — VMs dos Worker Nodes (multi-select dinamico filtrado pelo cloud)
  option_type {
    name             = "${var.workflow_name}-worker-vms"
    code             = "${var.workflow_name}-worker-vms"
    description      = "VMs to use as Kubernetes worker nodes"
    type             = "servers-input"
    field_label      = "Worker Node VMs"
    field_name       = "worker_vms"
    required         = true
    cloud_field_type = "field"
    cloud_field      = "cloud"
    help_block       = "Select one or more VMs for workers. Minimum: 2 vCPU, 2 GB RAM, Linux."
  }

  # Campo 7 — Pod Network CIDR (opcional, default Flannel)
  option_type {
    name          = "${var.workflow_name}-pod-cidr"
    code          = "${var.workflow_name}-pod-cidr"
    description   = "CIDR block for the pod network"
    type          = "text"
    field_label   = "Pod Network CIDR"
    field_name    = "pod_network_cidr"
    required      = false
    default_value = "10.244.0.0/16"
    help_block    = "Default: 10.244.0.0/16 (Flannel). Change if it conflicts with existing network ranges."
  }

  # Campo 8 — Perfil de add-ons recomendado para o cluster.
  option_type {
    name           = "${var.workflow_name}-addon-profile"
    code           = "${var.workflow_name}-addon-profile"
    description    = "Recommended add-on profile for the cluster"
    type           = "select"
    field_label    = "Add-on Profile"
    field_name     = "addon_profile"
    required       = true
    option_list_id = hpe_morpheus_option_list_manual.addon_profiles.id
    default_value  = "standard"
    help_block     = "Choose a recommended profile to guide the curated platform add-on selection."
  }

  # Campo 9 — CNI obrigatoria para tornar o cluster funcional.
  option_type {
    name            = "${var.workflow_name}-cni-addon"
    code            = "${var.workflow_name}-cni-addon"
    description     = "Container Network Interface selection"
    type            = "select"
    field_label     = "CNI"
    field_name      = "cni_addon"
    required        = true
    option_list_id  = hpe_morpheus_option_list_manual.cni_addons.id
    dependent_field = "addon_profile"
    default_value   = "flannel"
    help_block      = "Select the network plugin that will be installed after kubeadm init. Supported automation: Flannel or Calico."
  }

  # Campo 10 — CSI para provisionamento de storage.
  option_type {
    name            = "${var.workflow_name}-csi-addon"
    code            = "${var.workflow_name}-csi-addon"
    description     = "Container Storage Interface selection"
    type            = "select"
    field_label     = "CSI"
    field_name      = "csi_addon"
    required        = true
    option_list_id  = hpe_morpheus_option_list_manual.csi_addons.id
    dependent_field = "addon_profile"
    default_value   = "none"
    help_block      = "Select the storage integration. Supported automation: None or Local Path Provisioner."
  }

  # Campo 11 — Ingress controller para exposicao HTTP/HTTPS.
  option_type {
    name            = "${var.workflow_name}-ingress-addon"
    code            = "${var.workflow_name}-ingress-addon"
    description     = "Ingress controller selection"
    type            = "select"
    field_label     = "Ingress Controller"
    field_name      = "ingress_addon"
    required        = true
    option_list_id  = hpe_morpheus_option_list_manual.ingress_addons.id
    dependent_field = "addon_profile"
    default_value   = "none"
    help_block      = "Select the ingress controller. Supported automation: None or ingress-nginx."
  }

  # Campo 12 — Observabilidade opcional com multi-select.
  option_type {
    name                      = "${var.workflow_name}-observability-addons"
    code                      = "${var.workflow_name}-observability-addons"
    description               = "Observability add-ons for metrics and logs"
    type                      = "typeahead"
    field_label               = "Observability Add-ons"
    field_name                = "observability_addons"
    required                  = false
    option_list_id            = hpe_morpheus_option_list_manual.observability_addons.id
    dependent_field           = "addon_profile"
    allow_multiple_selections = true
    delimiter                 = ","
    help_block                = "Select optional observability components. Supported automation: metrics-server."
  }

  # Campo 13 — Add-ons de seguranca opcionais.
  option_type {
    name                      = "${var.workflow_name}-security-addons"
    code                      = "${var.workflow_name}-security-addons"
    description               = "Security and secret management add-ons"
    type                      = "typeahead"
    field_label               = "Security Add-ons"
    field_name                = "security_addons"
    required                  = false
    option_list_id            = hpe_morpheus_option_list_manual.security_addons.id
    dependent_field           = "addon_profile"
    allow_multiple_selections = true
    delimiter                 = ","
    help_block                = "Select optional security components. Supported automation: cert-manager, Sealed Secrets, Kyverno."
  }

  # Campo 14 — Add-ons GitOps opcionais.
  option_type {
    name                      = "${var.workflow_name}-gitops-addons"
    code                      = "${var.workflow_name}-gitops-addons"
    description               = "GitOps add-ons for application delivery"
    type                      = "typeahead"
    field_label               = "GitOps Add-ons"
    field_name                = "gitops_addons"
    required                  = false
    option_list_id            = hpe_morpheus_option_list_manual.gitops_addons.id
    dependent_field           = "addon_profile"
    allow_multiple_selections = true
    delimiter                 = ","
    help_block                = "Select optional GitOps components. Supported automation: Argo CD."
  }
}
