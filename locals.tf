locals {
  tfc_project_id = data.tfc_project.main.id

  tfc_variable_set_id = {
    "host-vpc-project" = tfe_variable_set.host_vpc_project.id
    "service-project"  = tfe_variable_set.service_project.id
  }

  tfc_gcp_service_account = {
    for r in local.tfc_roles_set : r => {
      "id"    = google_service_account.tfc_gcp[r].name
      "email" = google_service_account.tfc_gcp[r].email
      "self"  = "serviceAccount:${google_service_account.tfc_gcp[r].email}"
    }
  }

  # Terraform Cloud OpenID identity provider
  tfc_certificate_url_string = "https://${var.tfc_hostname}"
  tfc_certificate_url        = data.tls_certificate.tfc_certificate.url

  tfc_roles_set = toset(
    [
      "plan",
      "apply",
    ]
  )

  # A GCP Workload Identity Pool is a container for a GCP Workload Identity Pool Provider. 
  # A GCP Workload Identity Pool Provider can support either the OIDC or the SAML 2.0 standards.
  tfc_gcp_workload_identity_pool_id_string = "terraform-cloud-${random_integer.number.id}"
  tfc_gcp_workload_identity_pool_id        = google_iam_workload_identity_pool.tfc_gcp.workload_identity_pool_id
  tfc_gcp_workload_identity_pool_name      = google_iam_workload_identity_pool.tfc_gcp.name

  # The GCP IAM workload identity pool provider must be set up to point to the Terraform cloud OIDC identity provider.
  tfc_gcp_oidc_identity_provider_id_string = replace(var.tfc_hostname, ".", "-")
  tfc_gcp_oidc_identity_provider_id        = google_iam_workload_identity_pool_provider.tfc_gcp.id
  tfc_gcp_oidc_identity_provider_name      = google_iam_workload_identity_pool_provider.tfc_gcp.name

  # The audience/client for the identity tokens from the Terraform Cloud identity provider
  tfc_gcp_audience = "//iam.googleapis.com/projects/${local.terraform_admin_project_number}/locations/global/workloadIdentityPools/${local.tfc_gcp_workload_identity_pool_id_string}/providers/${local.tfc_gcp_oidc_identity_provider_id_string}"

  tfc_gcp_workload_identity_principal_set = "principalSet://iam.googleapis.com/${local.tfc_gcp_workload_identity_pool_name}/*"

  tfc_gcp_workspace_subject_value = <<EOF
assertion.sub.startsWith("organization:${var.tfc_organization_name}:project:${local.tfc_project_name["host-vpc-project"]}:workspace") ||
assertion.sub.startsWith("organization:${var.tfc_organization_name}:project:${local.tfc_project_name["service-project"]}:workspace")
EOF


  oidc_attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }

  gcp_iam_role = {
    "billing-account-user"     = "roles/billing.user"
    "folder-admin"             = "roles/resourcemanager.folderAdmin"
    "owner"                    = "roles/owner"
    "org-admin"                = "roles/resourcemanager.organizationAdmin"
    "org-policy-admin"         = "roles/orgpolicy.policyAdmin"
    "org-role-admin"           = "roles/iam.organizationRoleAdmin"
    "project-creator"          = "roles/resourcemanager.projectCreator"
    "project-deleter"          = "roles/resourcemanager.projectDeleter"
    "project-mover"            = "roles/resourcemanager.projectMover"
    "quota-admin"              = "roles/servicemanagement.quotaAdmin"
    "service-management-admin" = "roles/servicemanagement.admin"
    "shared-vpc-admin"         = "roles/compute.xpnAdmin"
    "workload-identity-admin"  = "roles/iam.workloadIdentityPoolAdmin"
    "workload-identity-user"   = "roles/iam.workloadIdentityUser"
    "viewer"                   = "roles/viewer"
  }

  gcp_folder_admin_roles_list = [
    "folder-admin",
    "project-creator",
    "project-deleter",
    "project-mover",
    "quota-admin",
    "service-management-admin",
    "workload-identity-admin",
  ]

  gcp_org_admin_roles_list = concat(
    local.gcp_folder_admin_roles_list,
    [
      "org-admin",
      "org-policy-admin",
      "org-role-admin",
    ]
  )

  gcp_admin_roles_list = {
    "folder" = local.gcp_folder_admin_roles_list
    "org"    = local.gcp_org_admin_roles_list
  }

  gcp_folder_id                  = var.gcp_folder_id == null ? "folders/" : "folders/${var.gcp_folder_id}"
  terraform_admin_project_number = data.google_project.terraform_admin.number
}
