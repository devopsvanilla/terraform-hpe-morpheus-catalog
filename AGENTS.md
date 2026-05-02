# Customization Index / Índice de Customizações

<!-- PT: Este arquivo lista todas as customizações de Copilot disponíveis neste repositório. -->
<!-- EN: This file lists all Copilot customizations available in this repository. -->

## Quick Decision Tree / Árvore de Decisão Rápida

```
What do you want to do?
│
├── Create a new catalog item (one)
│   └── /morpheus-catalog-item-factory
│
├── Create multiple catalog items at once
│   └── @batch-catalog-factory
│
├── Review a terraform plan before applying
│   └── /validate-catalog-plan
│
├── Diagnose unexpected drift or plan differences
│   └── /troubleshoot-catalog-drift
│
└── Something else → ask Copilot directly
```

---

## Skills / Habilidades

| Name / Nome | Trigger / Gatilho | Purpose / Propósito |
|---|---|---|
| `morpheus-catalog-item-factory` | `/morpheus-catalog-item-factory` | Scaffold Terraform files for a single Morpheus catalog item (instance, workflow, or app_blueprint). Asks for required inputs and runs fmt/validate. |

**File:** [.github/skills/morpheus-catalog-item-factory/SKILL.md](.github/skills/morpheus-catalog-item-factory/SKILL.md)

---

## Prompts / Prompts

| Name / Nome | Trigger / Gatilho | Purpose / Propósito |
|---|---|---|
| `validate-catalog-plan` | `/validate-catalog-plan` | Runs a structured pass/fail checklist over a `terraform plan` output before `apply`. Catches missing required fields, secrets, destructive ops, and label version issues. |
| `troubleshoot-catalog-drift` | `/troubleshoot-catalog-drift` | Diagnoses and remediates drift between Terraform state and Morpheus. Covers out-of-band edits, orphaned resources, missing state, and provider version drift. |

**Files:**
- [.github/prompts/validate-catalog-plan.prompt.md](.github/prompts/validate-catalog-plan.prompt.md)
- [.github/prompts/troubleshoot-catalog-drift.prompt.md](.github/prompts/troubleshoot-catalog-drift.prompt.md)

---

## Agents / Agentes

| Name / Nome | Trigger / Gatilho | Purpose / Propósito |
|---|---|---|
| `batch-catalog-factory` | `@batch-catalog-factory` | Creates multiple catalog items in one session. Validates inputs, scaffolds directories, runs fmt/init/validate per item, and returns a batch summary. Stops before `plan` and `apply`. |

**File:** [.github/agents/batch-catalog-factory.agent.md](.github/agents/batch-catalog-factory.agent.md)

---

## Global Instructions / Instruções Globais

Applies to all interactions in this repository:

**File:** [.github/copilot-instructions.md](.github/copilot-instructions.md)

Key rules:
- Mandatory workflow: `fmt → init → validate → plan → apply`
- Never hardcode credentials in Terraform files
- Use variable names from the naming convention table
- Prefer `file()` for large `config`, `content`, and `app_spec` values
