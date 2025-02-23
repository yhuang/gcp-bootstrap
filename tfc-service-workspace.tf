data "tfe_workspace" "service_project" {
  name         = "service-project"
  organization = var.tfc_organization_name
}

data "tfe_variable_set" "service_project_credentials" {
  name         = "service-projec-credentials"
  organization = var.tfc_organization_name
}

# The following variables must be set to enable a Terraform workspace to use the
# OIDC-compliant workload identity tokens to authenticate with GCP.
#s
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_gcp_provider_auth" {
  variable_set_id = local.tfc_variable_set_id["service-project-credentials"]

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"
}

resource "tfe_variable" "tfc_gcp_oidc_identity_provider_name" {
  variable_set_id = local.tfc_variable_set_id["service-project-credentials"]

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = local.tfc_gcp_oidc_identity_provider_name
  category = "env"
}

resource "tfe_variable" "tfc_gcp_plan_service_account_email" {
  variable_set_id = local.tfc_variable_set_id["service-project-credentials"]

  key      = "TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["plan"]["email"]
  category = "env"
}

resource "tfe_variable" "tfc_gcp_apply_service_account_email" {
  variable_set_id = local.tfc_variable_set_id["service-project-credentials"]

  key      = "TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL"
  value    = local.tfc_gcp_service_account["apply"]["email"]
  category = "env"
}

resource "tfe_variable" "tfc_gcp_audience" {
  variable_set_id = local.tfc_variable_set_id["service-project-credentials"]

  key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
  value    = local.tfc_gcp_audience
  category = "env"
}
