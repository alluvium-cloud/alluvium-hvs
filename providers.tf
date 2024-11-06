provider "hcp" {
}

provider "aws" {
  region = var.aws_region
}

provider "tfe" {
  organization = var.tfc_organization_name
}
