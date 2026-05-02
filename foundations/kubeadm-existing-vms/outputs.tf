output "workflow_id" {
  description = "Morpheus workflow ID — use como workflow_id no item de catalogo"
  value       = hpe_morpheus_workflow_operational.kubeadm.id
}

output "form_id" {
  description = "Morpheus form ID — use como form_id no item de catalogo"
  value       = hpe_morpheus_form.kubeadm_request.id
}

output "k8s_versions_option_list_id" {
  description = "Option list ID para versoes de Kubernetes"
  value       = hpe_morpheus_option_list_manual.k8s_versions.id
}

output "addon_profiles_option_list_id" {
  description = "Option list ID para perfis de add-ons"
  value       = hpe_morpheus_option_list_manual.addon_profiles.id
}

output "cni_addons_option_list_id" {
  description = "Option list ID para CNIs"
  value       = hpe_morpheus_option_list_manual.cni_addons.id
}

output "csi_addons_option_list_id" {
  description = "Option list ID para CSIs"
  value       = hpe_morpheus_option_list_manual.csi_addons.id
}

output "ingress_addons_option_list_id" {
  description = "Option list ID para ingress controllers"
  value       = hpe_morpheus_option_list_manual.ingress_addons.id
}

output "observability_addons_option_list_id" {
  description = "Option list ID para add-ons de observabilidade"
  value       = hpe_morpheus_option_list_manual.observability_addons.id
}

output "security_addons_option_list_id" {
  description = "Option list ID para add-ons de seguranca"
  value       = hpe_morpheus_option_list_manual.security_addons.id
}

output "gitops_addons_option_list_id" {
  description = "Option list ID para add-ons GitOps"
  value       = hpe_morpheus_option_list_manual.gitops_addons.id
}

output "task_prereqs_id" {
  value = hpe_morpheus_task_shell_script.prereqs.id
}

output "task_control_plane_init_id" {
  value = hpe_morpheus_task_shell_script.control_plane_init.id
}

output "task_control_plane_join_id" {
  value = hpe_morpheus_task_shell_script.control_plane_join.id
}

output "task_worker_join_id" {
  value = hpe_morpheus_task_shell_script.worker_join.id
}

output "task_platform_addons_id" {
  value = hpe_morpheus_task_shell_script.platform_addons.id
}
