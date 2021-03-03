resource "google_sourcerepo_repository" "repository" {
  name    = var.repository_name
  project = var.project_id
}
