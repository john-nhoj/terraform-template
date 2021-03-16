resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "container_registry_binding" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
