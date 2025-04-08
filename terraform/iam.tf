# Service Account for GKE Nodes
resource "google_service_account" "gke_node_sa" {
  project      = google_project.new_project.project_id
  account_id   = "gke-node-sa"
  display_name = "Service Account for GKE Nodes"
  description  = "Used by GKE node pools to interact with Google Cloud APIs"
}

# Grant necessary roles to the GKE Node Service Account
# Principle of least privilege: Grant only what's needed.
# Monitoring/Logging writers are often required.
# roles/storage.objectViewer might be needed if nodes pull from GCS.
resource "google_project_iam_member" "gke_node_sa_roles" {
  project = google_project.new_project.project_id
  for_each = toset([
    "roles/monitoring.metricWriter",    # Write metrics to Cloud Monitoring
    "roles/logging.logWriter",          # Write logs to Cloud Logging
    "roles/stackdriver.resourceMetadata.writer", # Write resource metadata
    "roles/storage.objectViewer",       # Allow pulling container images from GCR/AR (if private)
    # Add other roles if nodes need access to more services (e.g., Pub/Sub, SQL)
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.gke_node_sa.email}"

  depends_on = [google_project_service.apis]
}
