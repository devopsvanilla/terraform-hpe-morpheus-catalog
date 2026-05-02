---
name: validate-catalog-plan
description: 'Review a terraform plan output for Morpheus catalog items before apply. Use when: validar plan, check plan output, review plan before apply, plan review, preflight check, plano Morpheus catálogo.'
argument-hint: 'Paste the terraform plan output and specify: item type (instance|workflow|app_blueprint) and Morpheus version.'
---

# Validate Catalog Plan / Validar Plano de Catálogo

Review a `terraform plan` output for a Morpheus catalog item resource and produce a structured pass/fail checklist before the user runs `apply`.

## Inputs Required / Entradas Necessárias

Collect these before proceeding. If missing, ask.

1. `plan_output` — full text of `terraform plan` (or `terraform plan -out plan.tfplan && terraform show plan.tfplan`)
2. `item_type` — `instance`, `workflow`, or `app_blueprint`
3. `morpheus_version` — e.g. `5.5.3`, `6.0.1` (needed to flag label compatibility)

---

## Validation Checklist / Checklist de Validação

Work through each section. Report PASS, FAIL, or WARN with a one-line explanation.

### 1. Required Fields / Campos Obrigatórios

Verify the plan includes all required attributes for the item type.

| Item type | Required attributes |
|---|---|
| `instance` | `name`, `visibility`, `config` |
| `workflow` | `name`, `visibility`, `workflow_id` |
| `app_blueprint` | `name`, `visibility`, `blueprint_id`, `app_spec` |

- FAIL if any required attribute is missing or shows `(known after apply)` for a value that should be known now.

### 2. Visibility Value / Valor de Visibilidade

- FAIL if `visibility` is not `"public"` or `"private"`.
- WARN if `visibility = "public"` is used on a non-shared item — confirm intent.

### 3. Secret Safety / Segurança de Segredos

- Scan plan output for any literal token, password, or URL containing credentials.
- FAIL if any sensitive value appears in plain text in the plan diff.
- PASS if `morpheus_access_token` shows `(sensitive value)`.

### 4. Label Compatibility / Compatibilidade de Labels

- If `labels` is set AND `morpheus_version` < `5.5.3` → FAIL with remediation: remove `labels` or upgrade Morpheus.
- If `morpheus_version` is unknown → WARN.

### 5. Destructive Operations / Operações Destrutivas

- FAIL if plan contains any `destroy` for a catalog item resource. Ask user to confirm intent before proceeding.
- WARN if plan shows `replace` (destroy + create); explain impact on existing catalog item in Morpheus UI.

### 6. Resource Count Sanity / Sanidade de Contagem de Recursos

- WARN if plan will create more than 10 catalog items in a single apply — recommend batch agent for large sets.
- FAIL if plan shows 0 changes and user expected changes (possible variable override or state issue).

### 7. Provider Version / Versão do Provider

- FAIL if provider version constraint in plan is `< 1.3.0`.
- WARN if version is unconstrained (`>= 1.0.0` with no upper bound) — recommend pinning minor version.

---

## Output Format / Formato de Saída

Return a concise report structured as:

```
## Plan Validation Report

| Check | Status | Detail |
|---|---|---|
| Required fields | PASS/FAIL/WARN | ... |
| Visibility value | PASS/FAIL/WARN | ... |
| Secret safety | PASS/FAIL/WARN | ... |
| Label compatibility | PASS/FAIL/WARN | ... |
| Destructive operations | PASS/FAIL/WARN | ... |
| Resource count | PASS/FAIL/WARN | ... |
| Provider version | PASS/FAIL/WARN | ... |

**Overall: SAFE TO APPLY** or **DO NOT APPLY — fix items above first**

### Corrective Actions
<list each FAIL with exact fix>
```

---

## References / Referências

- Required field matrix: [field-matrix.md](../skills/morpheus-catalog-item-factory/references/field-matrix.md)
- Catalog item skill: [SKILL.md](../skills/morpheus-catalog-item-factory/SKILL.md)
