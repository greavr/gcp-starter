# Create the new Google Cloud Project within the Assured Workloads folder
resource "google_project" "new_project" {
  project_id      = local.project_id
  name            = local.project_id
  billing_account = var.billing_account
  folder_id       = var.assured_workloads_folder_id # Assign project to the AW folder
  org_id          = var.org_id                      # Org ID is required when using folder_id
}

# Enable required APIs for the project
resource "google_project_service" "apis" {
  project  = google_project.new_project.project_id
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "storage-component.googleapis.com",
    "storage-api.googleapis.com",
    "artifactregistry.googleapis.com",
    "firestore.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com", # For Private Service Access
    "assuredworkloads.googleapis.com"   # API for Assured Workloads
  ])
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false # Consider setting to true for full cleanup

  # Ensure project exists before trying to enable APIs
  depends_on = [google_project.new_project]
}