resource "hcp_vault_secrets_app" "this" {
  app_name    = "aws-alluvium"
  description = "Alluvium AWS OIDC"
  project_id  = var.hcp_project_id
}

resource "hcp_vault_secrets_secret" "this" {
  app_name     = hcp_vault_secrets_app.this.app_name
  secret_name  = "username"
  secret_value = "hashi123"
}

resource "hcp_vault_secrets_dynamic_secret" "this" {
  app_name         = hcp_vault_secrets_app.this.app_name
  project_id       = var.hcp_project_id
  secret_provider  = "aws"
  name             = "aws_alluvium"
  integration_name = "aws-alluvium"
  default_ttl      = "900s"
  aws_assume_role = {
    iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.hvs_role_dynamic_secrets.name}"
  }
}

resource "hcp_vault_secrets_integration_aws" "this" {
  name         = "aws-alluvium"
  capabilities = ["DYNAMIC", "ROTATION"]
  federated_workload_identity = {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.hvs_role_identity.name}"
    audience = var.hvs_aws_audience
  }
}
