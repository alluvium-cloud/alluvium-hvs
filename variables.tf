variable "aws_region" {
  description = "Region for the AWS VPC"
}

variable "hvs_aws_audience" {
  type = string
}

variable "hvs_openid_connect_url" {
  type = string
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with AWS"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "dynamic-credentials-trust-relationship"
  description = "The name of the workspace that you'd like to create and connect to AWS"
}

variable "hcp_project_id" {
  type = string
}
