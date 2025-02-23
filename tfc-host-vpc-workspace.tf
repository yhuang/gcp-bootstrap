resource "tfe_workspace" "host_vpc_project" {
  name       = "host-vpc-project"
  project_id = local.tfc_project_id
}

resource "tfe_variable_set" "host_vpc_project" {
  name              = "host-vpc-project"
  parent_project_id = local.tfc_project_id
}

# The following variables must be set to enable a Terraform workspace to use the
# OIDC-compliant workload identity tokens to authenticate with GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "host_vpc_project_enable_gcp_provider_auth" {
  variable_set_id = local.tfc_variable_set_id["host-vpc-project"]

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_oidc_identity_provider_name" {
  variable_set_id = local.tfc_variable_set_id["host-vpc-project"]

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = local.tfc_gcp_oidc_identity_provider_name
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_plan_service_account_email" {
  variable_set_id = local.tfc_variable_set_id["host-vpc-project"]

  key      = "TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["plan"]["email"]
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_apply_service_account_email" {
  variable_set_id = local.tfc_variable_set_id["host-vpc-project"]

  key      = "TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["apply"]["email"]
  category = "env"
}

resource "tfe_variable" "host_vpc_project_tfc_gcp_audience" {
  variable_set_id = local.tfc_variable_set_id["host-vpc-project"]

  key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
  value    = local.tfc_gcp_audience
  category = "env"
}
