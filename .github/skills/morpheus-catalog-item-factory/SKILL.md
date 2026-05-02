---
name: morpheus-catalog-item-factory
description: 'Create Terraform files for Morpheus catalog items using HPE provider. Use when: criar item de catalogo Morpheus, catalog item instance, catalog item workflow, catalog item app blueprint, scaffold Terraform catalog repository, validar plan before apply.'
argument-hint: 'Tipo do item (instance|workflow|app_blueprint), nome, visibilidade, e IDs requeridos.'
---

# Morpheus Catalog Item Factory

Create production-ready Terraform scaffolding for Morpheus catalog items in this repository.

## When to Use
- User asks to create a new catalog item in Morpheus.
- User needs Terraform files for `hpe_morpheus_catalog_item_instance`.
- User needs Terraform files for `hpe_morpheus_catalog_item_workflow`.
- User needs Terraform files for `hpe_morpheus_catalog_item_app_blueprint`.
- User wants a safe `fmt -> validate -> plan` workflow before `apply`.

## Inputs to Collect
Collect these first. If any required item is missing, ask for it before writing files.

1. Common inputs:
- `item_type`: `instance`, `workflow`, or `app_blueprint`
- `name`
- `visibility`: `public` or `private`
- `description` (optional but recommended)
- `category` (optional)
- `labels` (optional)

2. Type-specific required inputs:
- `instance`:
  - `config` JSON string or file content
- `workflow`:
  - `workflow_id`
- `app_blueprint`:
  - `blueprint_id`
  - `app_spec` YAML/JSON string or file path

3. Provider inputs:
- `morpheus_url`
- `morpheus_access_token`
- provider version constraint (default: `>= 1.3.0`)

## Procedure
1. Confirm target structure in this repo.
- Default structure:
  - `providers.tf`
  - `variables.tf`
  - `terraform.tfvars.example`
  - `catalog_item.tf`
  - optional content files (`catalog-content.md`, `appSpec.yaml`)

2. Create provider scaffolding from [provider template](./assets/provider.tf.tmpl).
- Use variables, not hardcoded secrets.

3. Choose the catalog resource template.
- `instance` -> [instance template](./assets/catalog_item_instance.tf.tmpl)
- `workflow` -> [workflow template](./assets/catalog_item_workflow.tf.tmpl)
- `app_blueprint` -> [app blueprint template](./assets/catalog_item_app_blueprint.tf.tmpl)

4. Fill required fields first, then optional fields.
- Required fields must be present before writing optional blocks.
- If `labels` are used, confirm Morpheus version supports them.

5. Add minimal outputs.
- Always output catalog item `id` and `name`.

6. Run validation commands in order.
- `terraform fmt -recursive`
- `terraform init`
- `terraform validate`
- `terraform plan`

7. Return a completion summary.
- Files created/changed
- Missing values still needed from user
- Any validation errors and next fix

## Decision Rules
- If user does not know IDs (`workflow_id`, `blueprint_id`), stop and ask for IDs or ask permission to add data sources if available.
- If `item_type` is unclear, propose the three supported options with one-line tradeoffs.
- If `content`, `config`, or `app_spec` is large, store it in dedicated files and reference with `file()`.
- If repository already has Terraform layout, preserve it and only add minimal required files.

## Quality Checklist
- Resource type matches requested `item_type`.
- Required attributes are present:
  - `instance`: `name`, `visibility`, `config`
  - `workflow`: `name`, `visibility`, `workflow_id`
  - `app_blueprint`: `name`, `visibility`, `blueprint_id`, `app_spec`
- No secret is hardcoded in `.tf` files.
- `terraform validate` succeeds.
- `terraform plan` shows only intended catalog item changes.

## References
- [Field matrix](./references/field-matrix.md)
