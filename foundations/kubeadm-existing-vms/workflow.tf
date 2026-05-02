# Workflow operacional que orquestra as 4 tasks kubeadm.
# O formulario (form_id) expoe os campos ao usuario no catalogo.
# A sequencia das tasks e: prereqs -> init -> join-cp -> join-workers.
resource "hpe_morpheus_workflow_operational" "kubeadm" {
  name                = var.workflow_name
  description         = var.workflow_description
  labels              = var.workflow_labels
  platform            = var.workflow_platform
  visibility          = var.workflow_visibility
  allow_custom_config = true

  task_ids = [
    hpe_morpheus_task_shell_script.prereqs.id,
    hpe_morpheus_task_shell_script.control_plane_init.id,
    hpe_morpheus_task_shell_script.control_plane_join.id,
    hpe_morpheus_task_shell_script.worker_join.id,
    hpe_morpheus_task_shell_script.platform_addons.id,
  ]
}
