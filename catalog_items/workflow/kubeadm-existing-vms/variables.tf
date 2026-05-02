variable "morpheus_url" {
  description = "Morpheus appliance URL / URL do appliance Morpheus"
  type        = string
}

variable "morpheus_access_token" {
  description = "Morpheus access token / Token de acesso Morpheus"
  type        = string
  sensitive   = true
}

variable "catalog_item_name" {
  description = "Catalog item name / Nome do item de catalogo"
  type        = string
  default     = "kubeadm-existing-vms"
}

variable "catalog_item_description" {
  description = "Catalog item description / Descricao do item"
  type        = string
  default     = "Install a Kubernetes cluster with kubeadm on existing Morpheus VMs"
}

variable "catalog_item_visibility" {
  description = "Catalog item visibility (public or private) / Visibilidade"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private"], var.catalog_item_visibility)
    error_message = "catalog_item_visibility must be public or private."
  }
}

variable "catalog_item_category" {
  description = "Catalog category / Categoria"
  type        = string
  default     = "kubernetes"
}

variable "catalog_item_labels" {
  description = "Catalog labels / Labels"
  type        = list(string)
  default     = ["kubernetes", "kubeadm", "existing-vms"]
}

variable "catalog_item_enabled" {
  description = "Whether the catalog item is enabled / Item habilitado"
  type        = bool
  default     = true
}

variable "catalog_item_featured" {
  description = "Whether the catalog item is featured / Item em destaque"
  type        = bool
  default     = false
}

variable "workflow_id" {
  description = "Morpheus workflow ID that performs kubeadm install / ID do workflow"
  type        = number
}

variable "form_id" {
  description = "Optional Morpheus form ID containing request fields / ID opcional do formulario"
  type        = number
  default     = null
}

variable "option_type_ids" {
  description = "Optional option type IDs when not using form_id / IDs de option type"
  type        = list(number)
  default     = []
}

variable "context_type" {
  description = "Workflow context type / Tipo de contexto"
  type        = string
  default     = "server"
}

variable "catalog_content_file" {
  description = "Path to markdown content shown in catalog UI / Caminho do conteudo markdown"
  type        = string
  default     = "content/catalog-content.md"
}
