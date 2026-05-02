# kubeadm-existing-vms foundations

<!-- PT: Stack base que cria os objetos Morpheus usados pelo item de catalogo. -->
<!-- EN: Base stack that creates the Morpheus objects used by the catalog item. -->

## Purpose / Proposito

This Terraform stack creates the Morpheus foundations required by the `kubeadm-existing-vms` workflow catalog item:
- Kubernetes version option list
- Request form
- Shell script tasks
- Operational workflow

The request form exposes these fields in cascade order:
- Morpheus group
- Morpheus cloud filtered by group
- Kubernetes version
- Cluster name
- Control Plane VM list filtered by cloud
- Worker VM list filtered by cloud
- Pod Network CIDR (optional)
- Add-on profile
- CNI
- CSI
- Ingress controller
- Observability add-ons
- Security add-ons
- GitOps add-ons

## Usage / Uso

```bash
cp terraform.tfvars.example terraform.tfvars
# edit values (never commit secrets)
terraform fmt -recursive
terraform init
terraform validate
terraform plan
# terraform apply  # only after plan review
```

## Outputs / Saidas

After apply, copy these outputs into `catalog_items/workflow/kubeadm-existing-vms/terraform.tfvars`:
- `workflow_id`
- `form_id`

Optional outputs for inspection:
- `k8s_versions_option_list_id`
- `addon_profiles_option_list_id`
- `cni_addons_option_list_id`
- `csi_addons_option_list_id`
- `ingress_addons_option_list_id`
- `observability_addons_option_list_id`
- `security_addons_option_list_id`
- `gitops_addons_option_list_id`
- `task_prereqs_id`
- `task_control_plane_init_id`
- `task_control_plane_join_id`
- `task_worker_join_id`
- `task_platform_addons_id`

## Notes / Notas

- Targets must already exist in Morpheus as manageable Linux servers.
- Group selection filters the available clouds.
- Cloud selection filters the available VM selectors.
- Add-on choices are curated to the components automated by the workflow today.
- The workflow installs the selected CNI, optional storage, ingress, observability, security, and GitOps components after the cluster joins complete.
- This stack creates workflow objects only; it does not publish the catalog item itself.

## Security / Seguranca

- Never hardcode credentials in tracked files.
- Keep `terraform.tfvars` local only.
- Keep `morpheus_access_token` with minimum required permissions.