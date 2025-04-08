

# 1. Create the new Google Cloud Project
resource "google_project" "new_project" {
  project_id      = var.new_project_id
  name            = coalesce(var.new_project_name, var.new_project_id)
  org_id          = var.org_id
  billing_account = var.billing_account_id
  folder_id       = var.new_project_folder_id

}

# 2. Enable necessary APIs on the new project
resource "google_project_service" "apis" {
  depends_on = [google_project.new_project]

  for_each = toset(var.apis_to_enable)

  project                    = google_project.new_project.project_id
  service                    = each.key
  disable_dependent_services = false 
  disable_on_destroy         = false 

}

# 3. Create the GCS bucket in the new project
resource "google_storage_bucket" "build_artifacts_bucket" {
  depends_on = [google_project_service.apis["storage.googleapis.com"]]

  project       = google_project.new_project.project_id
  name          = "${google_project.new_project.project_id}-${var.gcs_storage_name}"
  location      = var.gcs_bucket_location
  force_destroy = false 

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false # Set to true for production buckets to prevent accidental deletion
  }
}

# 4. Create the Artifact Registry repository in the new project
resource "google_artifact_registry_repository" "artifact_repo" {
  depends_on = [google_project_service.apis["artifactregistry.googleapis.com"]]

  project       = google_project.new_project.project_id
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repo_id
  description   = "Artifact Registry repository for Cloud Build"
  format        = "DOCKER" 
}

# 5. Create the custom IAM service account in the new project
resource "google_service_account" "custom_sa" {
  depends_on = [google_project_service.apis["iam.googleapis.com"]]

  project      = google_project.new_project.project_id
  account_id   = var.custom_sa_id
  display_name = var.custom_sa_display_name
  description  = "Service Account for executing Cloud Builds and managing project resources"
}

# 6. Grant necessary permissions to the custom Service Account

# 6a. Organization-level permissions (Requires high privilege for the Terraform runner!)
resource "google_organization_iam_member" "sa_org_project_creator" {
  depends_on = [google_service_account.custom_sa]

  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = google_service_account.custom_sa.member
}

resource "google_organization_iam_member" "sa_org_billing_user" {
  # Use depends_on to ensure the SA exists before assigning roles
  depends_on = [google_service_account.custom_sa]

  org_id = var.org_id
  role   = "roles/billing.user" 
  member = google_service_account.custom_sa.member
}

# 6b. Project-level permissions (On the newly created project)
# WARNING: 'roles/editor' is broad. Replace with specific roles needed for Cloud Build, GCS, AR, etc. for least privilege.
resource "google_project_iam_member" "sa_project_editor" {
  # Use depends_on to ensure the SA exists and the project exists
  depends_on = [google_service_account.custom_sa, google_project.new_project]

  project = google_project.new_project.project_id
  role    = "roles/editor" 
  member  = google_service_account.custom_sa.member
}
