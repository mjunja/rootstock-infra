# =============================================================================
# Shared config vars
# =============================================================================
# Non-sensitive config vars common to every Rootstock app live here so they can
# be changed in one place. App-specific config_vars are merged on top (the app
# value wins on conflict), so an individual app can still override these.
# =============================================================================

locals {
  base_config_vars = {
    DEFAULT_MONGODB = "ORMONGO"
  }

  config_vars = merge(local.base_config_vars, var.config_vars)
}
