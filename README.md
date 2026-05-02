# terraform-hpe-morpheus-catalog

<!-- PT: Repositório Terraform para gerenciar itens do Service Catalog do Morpheus Data Enterprise. -->
<!-- EN: Terraform configurations for managing Morpheus Data Enterprise Service Catalog items. -->

Manage Morpheus catalog items as code using the [HPE Terraform provider](https://registry.terraform.io/providers/HPE/hpe/latest/docs).

---

## Prerequisites / Pré-requisitos

| Tool | Minimum version |
|---|---|
| Terraform | 1.11.0 |
| HPE provider | 1.3.0 |
| Morpheus appliance | 5.5.0 (5.5.3+ for label support) |

---

## Quick Start — Single Catalog Item / Item Único

### 1. Scaffold with Copilot / Criar com Copilot

Open GitHub Copilot Chat and run:

```
/morpheus-catalog-item-factory Create a workflow catalog item named onboarding-linux, visibility public, workflow_id 42
```

The skill creates the directory structure and fills required fields.

### 2. Set credentials / Configurar credenciais

```bash
cd catalog_items/workflow/onboarding-linux
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — never commit this file
```

`terraform.tfvars` is gitignored. Set at minimum:

```hcl
morpheus_url          = "https://your-morpheus-appliance.example.com"
morpheus_access_token = "your-token-here"
```

### 3. Apply / Aplicar

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan          # Review output carefully before continuing
terraform apply
```

**Never run `apply` without reviewing the `plan` output first.**

---

## Quick Start — Multiple Items / Múltiplos Itens

Use the batch agent for two or more items:

```
@batch-catalog-factory

[
  { "type": "workflow", "name": "onboarding-linux", "visibility": "public", "workflow_id": 42 },
  { "type": "instance", "name": "dev-vm-ubuntu", "visibility": "private", "instance_config_file": "content/instance-config.json" }
]
```

The agent validates inputs, scaffolds all directories, and runs `fmt/init/validate` per item before returning a summary.

---

## Catalog Item Types / Tipos de Item

| Type | Resource | Required |
|---|---|---|
| Instance | `hpe_morpheus_catalog_item_instance` | `name`, `visibility`, `config` |
| Workflow | `hpe_morpheus_catalog_item_workflow` | `name`, `visibility`, `workflow_id` |
| App Blueprint | `hpe_morpheus_catalog_item_app_blueprint` | `name`, `visibility`, `blueprint_id`, `app_spec` |

---

## Repository Structure / Estrutura do Repositório

```
catalog_items/
  <type>/
    <item-name>/
      providers.tf
      variables.tf
      terraform.tfvars.example   # safe example — never real secrets
      catalog_item.tf
      outputs.tf
      content/                   # optional content files
.github/
  copilot-instructions.md        # global Copilot rules for this repo
  skills/
    morpheus-catalog-item-factory/
  prompts/
    validate-catalog-plan.prompt.md
    troubleshoot-catalog-drift.prompt.md
  agents/
    batch-catalog-factory.agent.md
AGENTS.md                        # full customization index
```

---

## Validation Before Apply / Validação Antes do Apply

Paste your `terraform plan` output into Copilot Chat:

```
/validate-catalog-plan

<paste terraform plan output here>
item_type: workflow
morpheus_version: 5.5.3
```

Returns a pass/fail checklist with corrective actions.

---

## Troubleshooting / Diagnóstico

If Terraform shows unexpected diffs or a resource was changed outside Terraform:

```
/troubleshoot-catalog-drift

terraform plan shows unexpected destroy for onboarding-linux
```

See [AGENTS.md](AGENTS.md) for the full customization index and decision tree.

---

## Security Notes / Notas de Segurança

- `terraform.tfvars` is gitignored — never commit credentials.
- Always use `sensitive = true` on token variables.
- Access tokens should have minimum required Morpheus permissions (catalog item create/update/delete).
