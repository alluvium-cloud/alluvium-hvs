resource "tfe_project" "this" {
  name = var.tfc_project_name
}

resource "tfe_workspace" "this" {
  name         = var.tfc_workspace_name
  description  = "TFC to HVS to AWS Workspace"
  organization = var.tfc_organization_name
  project_id   = tfe_project.this.id
  auto_apply   = true
}

resource "tfe_variable" "tfc_hcp_provider_auth" {
  key          = "TFC_HCP_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

resource "tfe_variable" "tfc_hcp_run_provider_resource_name" {
  key          = "TFC_HCP_RUN_PROVIDER_RESOURCE_NAME"
  value        = "iam/project/${var.hcp_project_id}/service-principal/${var.hcp_service_principal_name}/workload-identity-provider/${var.hcp_iam_workload_identity_provider_name}"
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

resource "tfe_variable" "tfc_hvs_backed_aws_auth" {
  key          = "TFC_HVS_BACKED_AWS_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

resource "tfe_variable" "tfc_hvs_backed_aws_run_secret_resource_name" {
  key          = "TFC_HVS_BACKED_AWS_RUN_SECRET_RESOURCE_NAME"
  value        = "secrets/project/${var.hcp_project_id}/geo/us/app/${var.hvs_integration_name}/secret/${var.hvs_secret_name}"
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

