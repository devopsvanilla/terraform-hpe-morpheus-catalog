# Morpheus Catalog Item Field Matrix

This matrix is based on `terraform-provider-hpe` docs and examples.

## Resource Types

1. `hpe_morpheus_catalog_item_instance`
- Required: `name`, `visibility`, `config`
- Optional (common): `description`, `category`, `enabled`, `featured`, `labels`, `form_id`, `option_type_ids`

2. `hpe_morpheus_catalog_item_workflow`
- Required: `name`, `visibility`, `workflow_id`
- Optional (common): `description`, `category`, `enabled`, `featured`, `labels`, `form_id`, `option_type_ids`
- Optional (type-specific): `context_type`, `content`, `logo_image_*`, `dark_logo_image_*`

3. `hpe_morpheus_catalog_item_app_blueprint`
- Required: `name`, `visibility`, `blueprint_id`, `app_spec`
- Optional (common): `description`, `category`, `enabled`, `featured`, `labels`, `form_id`, `option_type_ids`
- Optional (type-specific): `content`, `logo_image_*`, `dark_logo_image_*`

## Notes
- `labels` require Morpheus 5.5.3 or newer.
- For large `content`, `config`, and `app_spec`, prefer `file()` references.
- Always run `terraform validate` and `terraform plan` before `apply`.
