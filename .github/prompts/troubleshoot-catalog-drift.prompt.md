---
name: troubleshoot-catalog-drift
description: 'Diagnose state drift or unexpected changes in Morpheus catalog items managed by Terraform. Use when: estado divergente, drift, item mudou no Morpheus, terraform plan shows unexpected diff, state out of sync, resource changed outside Terraform.'
argument-hint: 'Describe what changed unexpectedly. Optionally paste terraform plan or terraform show output.'
---

# Troubleshoot Catalog Drift / Diagnosticar Divergência de Estado

Diagnose and safely remediate cases where a Morpheus catalog item managed by Terraform has drifted from the Terraform state.

## When to Use / Quando Usar

- `terraform plan` shows unexpected changes you did not make.
- A catalog item was modified directly in the Morpheus UI or API.
- `terraform apply` fails with a conflict or 404 error.
- The item exists in Morpheus but not in Terraform state (orphaned resource).
- The item exists in Terraform state but was deleted from Morpheus.

---

## Step 1: Identify Drift Type / Identificar Tipo de Divergência

Ask the user to describe the situation and map it to one of these categories:

| Category | Symptoms |
|---|---|
| **A. Out-of-band edit** | Plan shows diff you did not author; item was edited in Morpheus UI/API |
| **B. Missing resource** | `terraform plan` shows `create`; item already exists in Morpheus |
| **C. Deleted resource** | `terraform plan` or `apply` returns 404; item was removed from Morpheus |
| **D. State corruption** | State file is missing, stale, or locked |
| **E. Provider version drift** | Fields or defaults changed between provider versions |

---

## Step 2: Gather Evidence / Coletar Evidências

Request these outputs from the user before prescribing a fix:

1. `terraform show` — current state view
2. `terraform plan` — live diff
3. Morpheus UI screenshot or API response (if accessible)
4. Provider version: `terraform providers`
5. Any recent manual changes to Morpheus catalog items

---

## Step 3: Remediation Playbook / Playbook de Remediação

Follow the branch for the identified category. **Always run a plan after each remediation step.**

### A. Out-of-band edit (item changed in Morpheus)

**Option 1 — Accept Morpheus state as truth:**
```bash
terraform apply -refresh-only   # Sync state to current Morpheus values without changing resources
```
Then decide: keep Morpheus values or re-apply Terraform config.

**Option 2 — Restore Terraform config as truth:**
```bash
terraform plan   # Confirm diff
terraform apply  # Re-apply managed config to Morpheus
```
- Warn user: this will overwrite any Morpheus-side changes.

### B. Missing resource (exists in Morpheus, not in state)

Import the existing resource before creating a duplicate:
```bash
terraform import hpe_morpheus_catalog_item_<type>.<label> <morpheus_id>
terraform plan   # Should show no diff after import
```
- FAIL fast if import returns an error — do not run apply.

### C. Deleted resource (removed from Morpheus)

```bash
# Option 1: Remove from state and re-create
terraform state rm hpe_morpheus_catalog_item_<type>.<label>
terraform apply

# Option 2: Remove from state and from Terraform config
terraform state rm hpe_morpheus_catalog_item_<type>.<label>
# Then remove the resource block from .tf file
```
- Ask user which option before executing.

### D. State corruption or lock

```bash
# Check for lock
terraform force-unlock <lock-id>   # Only if lock is stale and confirmed safe

# Re-initialize if state backend issues
terraform init -reconfigure
terraform plan
```
- Never delete the `.tfstate` file directly — use `terraform state rm` or state backend tools.

### E. Provider version drift

1. Compare current provider version with the version that created the resource.
2. Check `CHANGELOG.md` in `terraform-provider-hpe` for breaking changes.
3. Pin the provider version in `providers.tf` and run `terraform init -upgrade`.
4. Run `terraform plan` and review all diffs before applying.

---

## Safety Rules / Regras de Segurança

- Never run `terraform destroy` as a drift fix without explicit user confirmation and a plan review.
- Never run `terraform apply` on a plan you have not read in full.
- `terraform state` edits are irreversible locally — backup state before any `state rm` or `state mv`.
- `force-unlock` is only safe when you are certain no other process holds the lock.

---

## References / Referências

- Catalog item field matrix: [field-matrix.md](../skills/morpheus-catalog-item-factory/references/field-matrix.md)
- Plan validation: [validate-catalog-plan.prompt.md](./validate-catalog-plan.prompt.md)
