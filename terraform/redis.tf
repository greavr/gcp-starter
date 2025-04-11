# Create Cloud Memorystore Redis Instance (HA) in each region
resource "google_redis_instance" "redis_ha" {
  provider         = google-beta 
  project          = google_project.new_project.project_id
  for_each         = var.regions
  name             = lower("${each.key}-redis")
  tier             = var.redis_tier 
  memory_size_gb   = var.redis_memory_size_gb
  location_id      = element(each.value.gke_node_zones, 0) 
  alternative_location_id = element(each.value.gke_node_zones, 1) # Failover zone (needs >= 2 zones in region)

  region = each.value.name

  # Network Configuration - Private IP required for Redis
  authorized_network = google_compute_network.vpc_network.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version    = "REDIS_7_0" # Or other supported version
  transit_encryption_mode = "SERVER_AUTHENTICATION" # Or DISABLED

  # Optional: Maintenance Policy
  # maintenance_policy {
  #   weekly_maintenance_window {
  #     day = "SATURDAY"
  #     start_time { hours = 0; minutes = 0; seconds = 0; nanos = 0 }
  #   }
  # }

  depends_on = [
    google_project_service.apis,
    google_compute_network.vpc_network,
    null_resource.wait_for_psa,
    # Dependency on service networking API being enabled
    google_project_service.apis["servicenetworking.googleapis.com"]
  ]
}
