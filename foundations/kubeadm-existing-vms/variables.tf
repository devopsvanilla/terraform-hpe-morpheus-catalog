variable "morpheus_url" {
  description = "Morpheus appliance URL / URL do appliance Morpheus"
  type        = string
}

variable "morpheus_access_token" {
  description = "Morpheus access token / Token de acesso Morpheus"
  type        = string
  sensitive   = true
}

variable "workflow_name" {
  description = "Name of the operational workflow / Nome do workflow operacional"
  type        = string
  default     = "kubeadm-existing-vms"
}

variable "workflow_description" {
  description = "Description of the operational workflow / Descricao do workflow"
  type        = string
  default     = "Installs Kubernetes with kubeadm on existing Morpheus VMs"
}

variable "workflow_visibility" {
  description = "Workflow visibility: public or private / Visibilidade do workflow"
  type        = string
  default     = "private"
}

variable "workflow_platform" {
  description = "Target OS platform / Plataforma do sistema operacional alvo"
  type        = string
  default     = "linux"
}

variable "workflow_labels" {
  description = "Labels applied to all workflow resources / Labels"
  type        = list(string)
  default     = ["kubernetes", "kubeadm", "existing-vms"]
}

variable "cloud_id" {
  description = "Morpheus cloud ID used to filter VM selectors / ID do cloud para filtrar VMs"
  type        = number
  default     = null
}
