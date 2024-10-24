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

data "aws_caller_identity" "current" {}

data "tls_certificate" "hvs_certificate" {
  url = "https://${var.hvs_openid_connect_url}"
}

resource "aws_iam_openid_connect_provider" "hvs" {
  url             = "https://${var.hvs_openid_connect_url}"
  client_id_list  = [var.hvs_aws_audience]
  thumbprint_list = [data.tls_certificate.hvs_certificate.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "hvs_role_identity" {
  name = "hvs_role_identity"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "${aws_iam_openid_connect_provider.hvs.arn}"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "${var.hvs_openid_connect_url}:aud": [
           "${one(aws_iam_openid_connect_provider.hvs.client_id_list)}"
         ]
       }
     }
   }
 ]
}
EOF
}

resource "aws_iam_role" "hvs_role_dynamic_secrets" {
  name = "hvs_role_dynamic_secrets"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "AWS": "${aws_iam_role.hvs_role_identity.arn}"
    },
    "Action": "sts:AssumeRole",
    "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_policy" "hvs_dynamic_secrets_policy" {
  name        = "hvs-policy"
  description = "HVS Policy"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "*"
      ],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_policy_attachment" {
  role       = aws_iam_role.hvs_role_dynamic_secrets.name
  policy_arn = aws_iam_policy.hvs_dynamic_secrets_policy.arn
}


resource "hcp_service_principal" "this" {
  name   = "tfc-sp"
  parent = "project/${var.hcp_project_id}"
}

resource "hcp_project_iam_binding" "this" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.this.resource_id
  role         = "roles/contributor"
}

resource "hcp_iam_workload_identity_provider" "aws" {
  name              = "hcp-terraform-aws"
  service_principal = hcp_service_principal.this.resource_name
  description       = "Allow my-app on AWS to act as my-app-runtime service principal"

  aws = {
    # Only allow workloads from this AWS Account to exchange identity
    account_id = data.aws_caller_identity.current.account_id
  }

  # Only allow workload's running with the correct AWS IAM Role
  conditional_access = "jwt_claims.sub matches `^organization:${var.tfc_organization_name}:project:Alluvium Cloud - Users:workspace:app-team-1:run_phase:.*`"

}
