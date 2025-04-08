# Create Cloud Storage Bucket in each region
resource "google_storage_bucket" "bucket" {
  project                     = google_project.new_project.project_id
  for_each                    = var.regions
  name                        = "${var.gcs_storage_name}-${each.value.name}"
  location                    = each.value.name
  force_destroy               = true 
  storage_class               = "STANDARD" 
  uniform_bucket_level_access = true      

  versioning {
    enabled = true
  }

#   lifecycle_rule {
#     action {
#       type = "Delete"
#     }
#     condition {
#       age = 30 # Example: Delete objects older than 30 days
#       # with_state = "ANY" # Can specify ARCHIVED, etc.
#     }
#   }
  # Enable logging and other features as needed
  # logging { ... }
  # website { ... }

  depends_on = [google_project_service.apis]
}