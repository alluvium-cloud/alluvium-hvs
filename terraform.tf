terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72.1"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.97.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.59.0"
    }
  }

  cloud {
    organization = "ericreeves-demo"
    hostname     = "app.terraform.io"

    workspaces {
      name    = "alluvium-hvs"
      project = "Alluvium Cloud"
    }
  }
}
