resource "tfe_workspace" "host_vpc_project" {
  name         = "host-vpc-project"
  organization = var.tfc_organization_name
  project_id   = local.tfc_project_id

  lifecycle {
    ignore_changes = [ vcs_repo ]
  }
}

# The following variables must be set to enable a Terraform workspace to use the
# OIDC-compliant workload identity tokens to authenticate with GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "host_vpc_project_enable_gcp_provider_auth" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_oidc_identity_provider_name" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = local.tfc_gcp_oidc_identity_provider_name
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_plan_service_account_email" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["plan"]["email"]
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_apply_service_account_email" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["apply"]["email"]
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_audience" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
  value    = local.tfc_gcp_audience
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_organization_name" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "tfc_organization_name"
  value    = var.tfc_organization_name
  category = "terraform"
}

resource "tfe_variable" "host_vpc_project_tfc_bootstrap_workspace_name" {
  workspace_id = local.tfc_workspace_id["host-vpc-project"]

  key      = "tfc_bootstrap_workspace_name"
  value    = "${terraform.workspace}"
  category = "terraform"
}