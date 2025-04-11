# Create the primary Artifact Registry repository in the primary region
resource "google_artifact_registry_repository" "primary_repo" {
  provider      = google-beta # Mirroring might require beta features
  project       = google_project.new_project.project_id
  location      = var.primary_region
  repository_id = "${local.project_id}-primary-repo-${lower(var.artifact_repo_format)}"
  description   = "Primary ${var.artifact_repo_format} repository"
  format        = var.artifact_repo_format # e.g., DOCKER, MAVEN, NPM

  depends_on = [google_project_service.apis]
}

# Create the mirror Artifact Registry repository in the secondary region(s)
resource "google_artifact_registry_repository" "mirror_repo" {
  provider = google
  project  = google_project.new_project.project_id
  for_each = { for k, v in var.regions : k => v if k != var.primary_region }

  location      = each.value.name
  repository_id = "${local.project_id}-mirror-repo-${each.key}-docker" # Explicitly docker
  description   = "Mirror DOCKER repository in ${each.key} pointing to ${var.primary_region}"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "pull-through cache of another Artifact Registry repository"
    common_repository {
      uri         = google_artifact_registry_repository.primary_repo.id
    }
  }

  depends_on = [google_artifact_registry_repository.primary_repo]
}