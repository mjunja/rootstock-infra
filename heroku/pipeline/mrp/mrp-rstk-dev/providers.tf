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

  # Uncomment and configure when ready for remote state
  # backend "s3" {
  #   bucket = "rootstock-tofu-state"
  #   key    = "heroku/apps/mrp-rstk-dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "heroku" {
  # Set via HEROKU_API_KEY environment variable
  # Or uncomment below:
  # api_key = var.heroku_api_key
}
