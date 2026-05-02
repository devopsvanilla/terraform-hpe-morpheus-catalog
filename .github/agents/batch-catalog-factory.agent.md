---
name: batch-catalog-factory
description: 'Create multiple Morpheus catalog items in a single session using the HPE Terraform provider. Use when: criar vários itens de catálogo, batch catalog items, multiple catalog items at once, lote de itens, criar família de catálogo, multiple workflows, multiple instances.'
---

# Batch Catalog Item Factory / Fábrica de Itens em Lote

Orchestrate creation of multiple Morpheus catalog items in a single session. Each item goes through the same scaffolding and validation loop used by the single-item skill.

## When to Use / Quando Usar

- You need to create 2 or more catalog items in one session.
- You have a list of items (name, type, IDs) ready to scaffold.
- You want a consistent structure across a family of related catalog items.

---

## Input Contract / Contrato de Entrada

Provide a JSON definition for each item. Collect this before starting.

```json
[
  {
    "type": "workflow",
    "name": "onboarding-linux",
    "visibility": "public",
    "description": "Linux VM onboarding workflow",
    "workflow_id": 42,
    "category": "Onboarding",
    "labels": ["linux", "onboarding"]
  },
  {
    "type": "instance",
    "name": "dev-vm-ubuntu",
    "visibility": "private",
    "description": "Ubuntu dev VM",
    "instance_config_file": "content/instance-config.json"
  },
  {
    "type": "app_blueprint",
    "name": "three-tier-app",
    "visibility": "public",
    "blueprint_id": 15,
    "app_spec_file": "content/appSpec.yaml"
  }
]
```

**Rules:**
- `type` must be `instance`, `workflow`, or `app_blueprint`.
- `name` must be kebab-case, no spaces.
- `visibility` must be `public` or `private`.
- Type-specific required fields: see [field matrix](../skills/morpheus-catalog-item-factory/references/field-matrix.md).

---

## Procedure / Procedimento

### Phase 1: Validate Input

1. Parse the JSON definition list.
2. For each item, check that all required fields are present.
3. Report a validation summary before creating any files:

```
Validation Summary:
  ✓ onboarding-linux (workflow) — all required fields present
  ✗ dev-vm-ubuntu (instance) — missing: instance_config_file content
  ✓ three-tier-app (app_blueprint) — all required fields present
```

4. Stop if any item has FAIL validation. Ask the user to provide missing fields before continuing.

### Phase 2: Scaffold All Items

For each valid item, create the directory and files under `catalog_items/<type>/<name>/`:

```
catalog_items/
  workflow/
    onboarding-linux/
      providers.tf
      variables.tf
      terraform.tfvars.example
      catalog_item.tf
      outputs.tf
  instance/
    dev-vm-ubuntu/
      ...
  app_blueprint/
    three-tier-app/
      ...
```

Use the corresponding asset template for each type:
- `workflow` → `.github/skills/morpheus-catalog-item-factory/assets/catalog_item_workflow.tf.tmpl`
- `instance` → `.github/skills/morpheus-catalog-item-factory/assets/catalog_item_instance.tf.tmpl`
- `app_blueprint` → `.github/skills/morpheus-catalog-item-factory/assets/catalog_item_app_blueprint.tf.tmpl`

### Phase 3: Validation Loop

For each scaffolded directory, run in sequence:

```bash
terraform fmt -recursive
terraform init
terraform validate
```

Report status per item:

```
Validation Loop:
  onboarding-linux  → fmt ✓  init ✓  validate ✓
  dev-vm-ubuntu     → fmt ✓  init ✓  validate ✗ (error detail)
  three-tier-app    → fmt ✓  init ✓  validate ✓
```

Stop before `terraform plan` for items with validate errors and show the exact error.

### Phase 4: Completion Summary

After all items are processed, return:

```
Batch Summary: 3 items requested, 2 ready for plan, 1 requires fix.

Ready for plan:
  - catalog_items/workflow/onboarding-linux
  - catalog_items/app_blueprint/three-tier-app

Needs fix:
  - catalog_items/instance/dev-vm-ubuntu
    Error: <exact terraform validate error>
    Fix: <corrective action>

Next step: run `terraform plan` in each ready directory and review before apply.
```

---

## Failure Handling / Tratamento de Falhas

- If a required field is missing: stop that item, report FAIL, continue with others.
- If `terraform validate` fails: stop that item, report error and fix hint, continue with others.
- If directory already exists: warn user, ask whether to overwrite or skip.
- Never proceed to `terraform plan` or `apply` for items that failed validation.

---

## Tool Restrictions / Restrições de Ferramentas

- Only create files in the `catalog_items/` directory tree.
- Never modify files in `.github/` unless explicitly asked.
- Never run `terraform apply` or `terraform destroy` — this agent stops at `validate`.

---

## References / Referências

- Single-item workflow: [SKILL.md](../skills/morpheus-catalog-item-factory/SKILL.md)
- Field matrix: [field-matrix.md](../skills/morpheus-catalog-item-factory/references/field-matrix.md)
- Plan validation: [validate-catalog-plan.prompt.md](../prompts/validate-catalog-plan.prompt.md)
