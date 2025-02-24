# Data source used to grab the TLS certificate for Terraform Cloud.
#
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate
data "tls_certificate" "tfc_certificate" {
  url = local.tfc_certificate_url_string
}

# Data source used to get the project number programmatically. If project_id is not provided, 
# the provider project becomes the subject.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project
data "google_project" "terraform_admin" {
}

# Creates a workload identity pool to house a workload identity pool provider.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool
resource "google_iam_workload_identity_pool" "tfc_gcp" {
  workload_identity_pool_id = local.tfc_gcp_workload_identity_pool_id_string
}

# Creates an identity pool provider which uses an attribute condition
# to ensure that only the specified Terraform Cloud workspace will be
# able to authenticate to GCP using this provider.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
resource "google_iam_workload_identity_pool_provider" "tfc_gcp" {
  workload_identity_pool_provider_id = local.tfc_gcp_oidc_identity_provider_id_string
  workload_identity_pool_id          = local.tfc_gcp_workload_identity_pool_id
  attribute_mapping                  = local.oidc_attribute_mapping
  oidc {
    issuer_uri = local.tfc_certificate_url_string
    # The default audience format used by TFC is of the form:
    # //iam.googleapis.com/projects/{project number}/locations/global/workloadIdentityPools/{pool ID}/providers/{provider ID}
    # which matches with the default accepted audience format on GCP.

    allowed_audiences = [local.tfc_gcp_audience]
  }
  attribute_condition = local.tfc_gcp_project_subject_value
}

# Creates service accounts that will be used for authenticating to GCP.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "tfc_gcp" {
  for_each = local.tfc_roles_set

  account_id   = "tfc-gcp-${each.value}-${random_integer.number.id}"
  display_name = "TFC-GCP ${title(each.value)} Service Account"
}

# Allows the workload identity to impersonate the service accounts.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "tfc_gcp" {
  for_each = local.tfc_roles_set

  service_account_id = local.tfc_gcp_service_account[each.value]["id"]
  role               = local.gcp_iam_role["workload-identity-user"]
  member             = local.tfc_gcp_workload_identity_principal_set
}

# Updates the IAM policy to grant the service account permissions within the organization.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam
resource "google_organization_iam_member" "tfc_gcp_apply" {
  count = startswith(local.gcp_folder_id, "folders/") ? 0 : length(local.gcp_admin_roles_list["org"])

  org_id = var.gcp_org_id
  role   = local.gcp_iam_role[local.gcp_admin_roles_list["org"][count.index]]
  member = local.tfc_gcp_service_account["apply"]["self"]
}

# Updates the IAM policy to grant the service account permissions within the organization.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam
resource "google_folder_iam_member" "tfc_gcp_apply" {
  count = startswith(local.gcp_folder_id, "folders/") ? length(local.gcp_admin_roles_list["folder"]) : 0

  folder = local.gcp_folder_id
  role   = local.gcp_iam_role[local.gcp_admin_roles_list["folder"][count.index]]
  member = local.tfc_gcp_service_account["apply"]["self"]
}

resource "google_billing_account_iam_member" "tfc_gcp_apply" {
  billing_account_id = var.gcp_billing_account_id
  role               = local.gcp_iam_role["billing-account-user"]
  member             = local.tfc_gcp_service_account["apply"]["self"]
}

# Updates the IAM policy to grant the service account permissions within the organization.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam
resource "google_organization_iam_member" "tfc_gcp_plan" {
  count = startswith(local.gcp_folder_id, "folders/") ? 0 : 1

  org_id = var.gcp_org_id
  role   = local.gcp_iam_role["viewer"]
  member = local.tfc_gcp_service_account["plan"]["self"]
}

# Updates the IAM policy to grant the service account permissions within the organization.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam
resource "google_folder_iam_member" "tfc_gcp_plan" {
  count = startswith(local.gcp_folder_id, "folders/") ? 0 : 1

  folder = local.gcp_folder_id
  role   = local.gcp_iam_role["viewer"]
  member = local.tfc_gcp_service_account["plan"]["self"]
}