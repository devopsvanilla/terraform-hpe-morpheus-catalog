# Copilot Instructions — terraform-hpe-morpheus-catalog

<!-- PT: Instruções globais para o agente Copilot neste repositório. -->
<!-- EN: Global Copilot agent instructions for this repository. -->

## Purpose / Propósito

**EN**: This repository stores Terraform configurations that manage Morpheus catalog items using the HPE Terraform provider (`HPE/hpe`, v1.3.0+). All code here provisions objects in the `Service Catalog` of a Morpheus Data Enterprise appliance.

**PT**: Este repositório armazena configurações Terraform que gerenciam itens do catálogo Morpheus usando o provider HPE (`HPE/hpe`, v1.3.0+). Todo o código aqui provisiona objetos no `Service Catalog` de um appliance Morpheus Data Enterprise.

---

## Mandatory Workflow / Fluxo Obrigatório

**Always run in this order. Never skip steps.**

```bash
terraform fmt -recursive      # Format code / Formata o código
terraform init                # Download provider / Baixa o provider
terraform validate            # Syntax check / Verifica sintaxe
terraform plan                # Preview changes / Pré-visualiza mudanças
# Review plan output before proceeding / Revise a saída antes de prosseguir
terraform apply               # Apply only after plan review / Aplique somente após revisão
```

- **Never run `apply` without a preceding `plan` in the same terminal session.**
- **Nunca execute `apply` sem um `plan` prévio na mesma sessão.**
- Flag any `destroy` operations explicitly before executing them.

---

## Provider Authentication / Autenticação do Provider

**EN**: Never hardcode credentials in `.tf` files. Always use input variables backed by `terraform.tfvars` (gitignored) or environment variables.

**PT**: Nunca coloque credenciais diretamente em arquivos `.tf`. Use sempre variáveis de entrada com `terraform.tfvars` (no `.gitignore`) ou variáveis de ambiente.

### Required provider block / Bloco de provider obrigatório

```hcl
terraform {
  required_version = ">= 1.11.0"
  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = ">= 1.3.0"
    }
  }
}

provider "hpe" {
  morpheus {
    access_token = var.morpheus_access_token
    url          = var.morpheus_url
  }
}
```

### Required variables / Variáveis obrigatórias

```hcl
variable "morpheus_url" {
  description = "Morpheus appliance URL / URL do appliance Morpheus"
  type        = string
}

variable "morpheus_access_token" {
  description = "Morpheus access token / Token de acesso Morpheus"
  type        = string
  sensitive   = true
}
```

---

## Catalog Item Types / Tipos de Item de Catálogo

Use the table below to choose the correct resource type.
Use a tabela abaixo para escolher o tipo de recurso correto.

| Intent / Intenção | Resource / Recurso | Required fields / Campos obrigatórios |
|---|---|---|
| Provision a VM or service instance | `hpe_morpheus_catalog_item_instance` | `name`, `visibility`, `config` |
| Run an operational workflow | `hpe_morpheus_catalog_item_workflow` | `name`, `visibility`, `workflow_id` |
| Deploy a full app blueprint | `hpe_morpheus_catalog_item_app_blueprint` | `name`, `visibility`, `blueprint_id`, `app_spec` |

### Decision rule / Regra de decisão

- When the user says "executar workflow" or "run workflow" → `catalog_item_workflow`.
- When the user says "provisionar VM/serviço" or "provision instance" → `catalog_item_instance`.
- When the user says "deploy de app" or "app blueprint" → `catalog_item_app_blueprint`.
- When unclear, ask before writing any file.

---

## Repository Layout / Estrutura do Repositório

**EN**: Each catalog item lives in its own directory. Shared provider config lives at the root or in a `base/` directory.

**PT**: Cada item de catálogo fica em seu próprio diretório. Configuração compartilhada do provider fica na raiz ou em um diretório `base/`.

```
catalog_items/
  <type>/
    <item-name>/
      providers.tf          # provider block + terraform block
      variables.tf          # all input variables
      terraform.tfvars.example  # safe example values, never real secrets
      catalog_item.tf       # the hpe_morpheus_catalog_item_* resource
      outputs.tf            # at minimum: id and name outputs
      README.md             # usage instructions (bilingual)
      content/
        catalog-content.md  # optional markdown displayed in catalog UI
        appSpec.yaml        # app_blueprint only
        instance-config.json  # instance only
```

---

## Naming Conventions / Convenções de Nomenclatura

**Resources:**
- Label: `<item_type>_<snake_case_name>` — e.g. `catalog_item_workflow_onboarding_linux`
- `name` attribute: kebab-case, no spaces — e.g. `"onboarding-linux"`

**Variables:**
- Provider: `morpheus_url`, `morpheus_access_token`
- Item: `catalog_item_name`, `catalog_item_description`, `catalog_item_visibility`, `catalog_item_category`, `catalog_item_labels`, `catalog_item_enabled`, `catalog_item_featured`
- Type-specific: `workflow_id`, `blueprint_id`, `app_spec_file`, `instance_config_file`, `catalog_content_file`, `option_type_ids`, `form_id`

**Files:** lowercase snake_case only. No spaces in filenames.

---

## Common Optional Fields / Campos Opcionais Comuns

All three resource types accept these optional fields:
- `description` — always recommended / sempre recomendado
- `category` — for catalog grouping / para agrupamento no catálogo
- `labels` — requires Morpheus ≥ 5.5.3 / exige Morpheus ≥ 5.5.3
- `enabled` — defaults to `true` / padrão `true`
- `featured` — highlights item in UI / destaca o item na UI
- `form_id` — links a custom form / vincula um formulário customizado
- `option_type_ids` — list of option type IDs / lista de IDs de tipos de opção
- `logo_image_name` / `logo_image_path` — catalog thumbnail (workflow + blueprint)
- `dark_logo_image_name` / `dark_logo_image_path` — dark mode thumbnail (workflow + blueprint)

---

## Security Rules / Regras de Segurança

1. Never write real credentials, tokens, or passwords in any `.tf`, `.md`, or `.yaml` file tracked by git.
2. Always include `sensitive = true` on `morpheus_access_token` and any password variable.
3. Add `terraform.tfvars` to `.gitignore` before writing any apply instructions.
4. Flag and refuse any request to embed a secret inline in a resource attribute.

---

## Customization Index / Índice de Customizações

| Type | File | Use when / Use quando |
|---|---|---|
| Skill | `.github/skills/morpheus-catalog-item-factory/SKILL.md` | Scaffolding a new catalog item from scratch |
| Prompt | `.github/prompts/validate-catalog-plan.prompt.md` | Reviewing a `terraform plan` output before apply |
| Prompt | `.github/prompts/troubleshoot-catalog-drift.prompt.md` | Diagnosing state drift or unexpected Morpheus changes |
| Agent | `.github/agents/batch-catalog-factory.agent.md` | Creating multiple catalog items in one session |

Use `/morpheus-catalog-item-factory` to start a new item interactively.

---

## Language / Idioma

- Write body text in English.
- Add Portuguese translation of headings and key instructions in comments or parallel bullet points.
- Examples (HCL, bash) need not be translated; use bilingual inline comments where helpful.
