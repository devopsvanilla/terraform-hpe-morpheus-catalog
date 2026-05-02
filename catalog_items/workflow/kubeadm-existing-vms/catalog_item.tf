resource "hpe_morpheus_catalog_item_workflow" "kubeadm_existing_vms" {
  name        = var.catalog_item_name
  description = var.catalog_item_description
  visibility  = var.catalog_item_visibility
  workflow_id = var.workflow_id

  category     = var.catalog_item_category
  enabled      = var.catalog_item_enabled
  featured     = var.catalog_item_featured
  labels       = var.catalog_item_labels
  context_type = var.context_type
  content      = file(var.catalog_content_file)

  # Use form_id OU option_type_ids — nunca os dois ao mesmo tempo.
  form_id         = var.form_id != null ? var.form_id : null
  option_type_ids = var.form_id == null ? var.option_type_ids : null
}
