output "tfc_gcp_audience" {
  value = local.tfc_gcp_audience
}

output "tfc_certificate_url" {
  value = local.tfc_certificate_url
}

output "tfc_gcp_workload_identity_pool_id" {
  value = local.tfc_gcp_workload_identity_pool_id
}

output "tfc_gcp_oidc_identity_provider_id" {
  value = local.tfc_gcp_oidc_identity_provider_id
}

output "tfc_gcp_oidc_identity_provider_name" {
  value = local.tfc_gcp_oidc_identity_provider_name
}

output "tfc_gcp_workload_identity_principal_set" {
  value = local.tfc_gcp_workload_identity_principal_set
}

output "terraform_admin_gcp_project_id" {
  value = var.terraform_admin_gcp_project_id
}

output "gcp_folder_id" {
  value = var.gcp_folder_id
}

output "gcp_billing_account_id" {
  value = var.gcp_billing_account_id
}