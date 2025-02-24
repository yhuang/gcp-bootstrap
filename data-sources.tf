data "tfe_project" "main" {
  organization = var.tfc_organization_name
  name         = var.tfc_project_name
}
