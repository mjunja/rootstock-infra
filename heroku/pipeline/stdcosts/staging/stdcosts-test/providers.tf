terraform {
  required_version = ">= 1.6.0"

  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Remote state: pg backend on grafana-stg's postgres (INTERIM - see .github/README.md).
  # Connection string comes from PG_CONN_STR env; state encryption via TF_ENCRYPTION.
  backend "pg" {
    schema_name = "stdcosts_test"
  }
}

provider "heroku" {
  # Set via HEROKU_API_KEY environment variable
}
