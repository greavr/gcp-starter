# Set up Firestore in Native mode for the project
resource "google_firestore_database" "database" {
  project     = google_project.new_project.project_id
  name        = "(default)"             # Required value for the default database
  location_id = var.firestore_location # e.g., "us-east1", "nam5", "eur3"
  type        = "FIRESTORE_NATIVE"      # Or "DATASTORE_MODE"

  depends_on = [google_project_service.apis]
}