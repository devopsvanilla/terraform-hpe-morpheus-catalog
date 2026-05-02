output "catalog_item_id" {
  description = "Catalog item ID"
  value       = hpe_morpheus_catalog_item_workflow.kubeadm_existing_vms.id
}

output "catalog_item_name" {
  description = "Catalog item name"
  value       = hpe_morpheus_catalog_item_workflow.kubeadm_existing_vms.name
}

output "workflow_id" {
  description = "Bound Morpheus workflow ID"
  value       = hpe_morpheus_catalog_item_workflow.kubeadm_existing_vms.workflow_id
}
