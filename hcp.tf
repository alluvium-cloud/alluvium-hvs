


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

  oidc = {
    issuer_uri = "https://app.terraform.io"
  }

  # Only allow workload's running with the correct AWS IAM Role
  conditional_access = "jwt_claims.sub matches `^organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:.*`"
}
