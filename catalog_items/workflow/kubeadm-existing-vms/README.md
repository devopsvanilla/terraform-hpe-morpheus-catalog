# kubeadm-existing-vms workflow catalog item

<!-- PT: Item de catalogo para instalar Kubernetes com kubeadm em VMs existentes no Morpheus. -->
<!-- EN: Catalog item to install Kubernetes with kubeadm on existing Morpheus VMs. -->

## Purpose / Proposito

This Terraform stack publishes a Morpheus workflow catalog item for Kubernetes installation with kubeadm on existing VMs.

The request form should expose these inputs:
- Morpheus group
- Morpheus cloud
- Kubernetes version
- Cluster name
- Control Plane VM list
- Worker VM list
- Pod Network CIDR (optional)
- Add-on profile
- CNI
- CSI
- Ingress controller
- Observability add-ons
- Security add-ons
- GitOps add-ons

## Required Morpheus objects / Objetos obrigatorios

Before running this stack, create these objects in Morpheus:
- A workflow that executes kubeadm tasks on selected VMs (`workflow_id`)
- A form with the request fields and filtering chain `group -> cloud -> VM selectors` (`form_id`), or option types (`option_type_ids`)

Recommended workflow:
- Apply `foundations/kubeadm-existing-vms` first to create the workflow, form, option list, and tasks.
- Copy `workflow_id` and `form_id` outputs from foundations into this stack.

## Files / Arquivos

- `providers.tf`: Terraform and provider configuration
- `variables.tf`: Input variables
- `catalog_item.tf`: `hpe_morpheus_catalog_item_workflow` resource
- `outputs.tf`: output values (`id`, `name`, `workflow_id`)
- `content/catalog-content.md`: markdown shown in catalog UI
- `content/scripts/*.sh`: starter script templates for workflow tasks

## Usage / Uso

```bash
cp ../../foundations/kubeadm-existing-vms/terraform.tfvars.example ../../foundations/kubeadm-existing-vms/terraform.tfvars
cd ../../foundations/kubeadm-existing-vms
terraform fmt -recursive
terraform init
terraform validate
terraform plan
# terraform apply  # only after plan review

cd ../../catalog_items/workflow/kubeadm-existing-vms
cp terraform.tfvars.example terraform.tfvars
# edit values (never commit secrets)
terraform fmt -recursive
terraform init
terraform validate
terraform plan
# terraform apply  # only after plan review
```

After applying the foundations stack, set these values in `terraform.tfvars` for this catalog item:
- `workflow_id = <output.workflow_id>`
- `form_id = <output.form_id>`

## Security / Seguranca

- Never hardcode credentials in tracked files.
- Keep `terraform.tfvars` local only.
- Keep `morpheus_access_token` with minimum required permissions.

## Supported Add-ons / Add-ons suportados

Current workflow automation supports these curated options:
- CNI: `flannel`, `calico`
- CSI: `none`, `local-path-provisioner`
- Ingress: `none`, `ingress-nginx`
- Observability: `metrics-server`
- Security: `cert-manager`, `sealed-secrets`, `kyverno`
- GitOps: `argocd`
