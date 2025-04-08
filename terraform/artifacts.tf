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
  provider      = google-beta
  project       = google_project.new_project.project_id
  # Create a mirror in each region *except* the primary region
  for_each      = { for k, v in var.regions : k => v if k != var.primary_region }
  location      = each.value.name
  repository_id = "${local.project_id}-mirror-repo-${each.key}-${lower(var.artifact_repo_format)}"
  description   = "Mirror ${var.artifact_repo_format} repository in ${each.key}"
  format        = var.artifact_repo_format
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    # Configuration depends heavily on the format (Docker, Maven, etc.)
    # This is a generic example for Docker; adjust as needed.
    description = "Mirroring ${google_artifact_registry_repository.primary_repo.repository_id}"

    # For Docker format:
    docker_repository {
      # Points to the primary repository within the same project
       public_repository = "projects/${google_project.new_project.project_id}/locations/${var.primary_region}/repositories/${google_artifact_registry_repository.primary_repo.repository_id}"
    }

    # Example for Maven (adjust upstream URI):
    # maven_repository {
    #   public_repository = "MAVEN_CENTRAL" # Or point to your primary repo URI if format supports direct URI
    # }

     # Example for Npm (adjust upstream URI):
    # npm_repository {
    #   public_repository = "NPMJS" # Or point to your primary repo URI if format supports direct URI
    # }
  }

  depends_on = [google_artifact_registry_repository.primary_repo]
}