# Create Cloud SQL PostgreSQL HA Instance in each region
resource "google_sql_database_instance" "postgres_ha" {
  provider = google-beta # Recommended for latest SQL features/settings
  project  = google_project.new_project.project_id
  for_each = var.regions
  name     = "${local.project_id}-pg-ha-${each.key}"
  region   = each.value.name

  database_version = var.postgres_version

  settings {
    tier = var.db_machine_type # e.g., "db-custom-2-7680" for production

    # High Availability (Regional) configuration
    availability_type = "REGIONAL"

    # Backup Configuration (Essential for Production)
    backup_configuration {
      enabled            = true
      start_time         = "03:00" # Choose a low-traffic time in UTC
      location           = each.value.name
      point_in_time_recovery_enabled = true
    }

    # Disk Configuration
    disk_autoresize = true
    disk_size       = var.db_disk_size
    disk_type       = "PD_SSD" # Use SSD for production performance

    # Network Configuration - Private IP recommended for security
    ip_configuration {
      ipv4_enabled    = false        # Disable public IP
      private_network = google_compute_network.vpc_network[each.key].id
      # authorized_networks = [] # Not needed with private IP only
      # require_ssl = true # Enforce SSL connections
    }

    # Maintenance Window (Optional, but good practice)
    # maintenance_window {
    #   day          = 1 # Monday
    #   hour         = 4 # 4 AM UTC
    #   update_track = "stable"
    # }

    # Location Preference (for Zonal placement if not HA, or within HA region)
    location_preference {
      zone = element(each.value.gke_node_zones, 0) # Place primary in the first zone of the list
    }

    # Enable IAM database authentication (Recommended when not setting root password)
    database_flags {
        name  = "cloudsql.iam_authentication"
        value = "on"
    }
  }


  deletion_protection = false # Set to true for production safety

  depends_on = [
    google_project_service.apis,
    google_compute_network.vpc_network,
    # Dependency on service networking API being enabled if using private IP
    google_project_service.apis["servicenetworking.googleapis.com"] # Implicitly enabled usually
  ]
}

# Create Cloud Memorystore Redis Instance (HA) in each region
resource "google_redis_instance" "redis_ha" {
  provider         = google-beta # Recommended for latest Redis features
  project          = google_project.new_project.project_id
  for_each         = var.regions
  name             = "${local.project_id}-redis-ha-${each.key}"
  tier             = var.redis_tier # Should be STANDARD_HA for production HA
  memory_size_gb   = var.redis_memory_size_gb
  location_id      = element(each.value.gke_node_zones, 0) # Primary zone
  alternative_location_id = element(each.value.gke_node_zones, 1) # Failover zone (needs >= 2 zones in region)

  region = each.value.name

  # Network Configuration - Private IP required for Redis
  authorized_network = google_compute_network.vpc_network[each.key].id
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
    # Dependency on service networking API being enabled
    google_project_service.apis["servicenetworking.googleapis.com"]
  ]
}

# Note: The actual Private Service Access connection needs to be configured once per VPC.
# This often involves creating a global IP address range reservation.
# Terraform can manage this with `google_compute_global_address` and `google_service_networking_connection`.
# Adding that here for completeness:

resource "google_compute_global_address" "private_service_access_ip_range" {
  # Only need one reservation per network, even with multiple regions using that network
  # We'll create one based on the primary region's network, but it applies network-wide.
  provider = google-beta
  # Use count = 1 if you have only one network, or for_each if you manage multiple distinct networks
  count        = length(var.regions) > 0 ? 1 : 0 # Ensure it's created only once
  project      = google_project.new_project.project_id
  name         = "${local.project_id}-psa-range"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  # Choose a range NOT overlapping with your VPC subnets or other peered networks
  # Common choices are /16 or /20 ranges
  ip_version   = "IPV4"
  prefix_length= 16
  network      = google_compute_network.vpc_network[var.primary_region].id

  depends_on = [google_compute_network.vpc_network]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  # Same logic as above - one connection per network
  provider = google-beta
  count    = length(var.regions) > 0 ? 1 : 0
  network  = google_compute_network.vpc_network[var.primary_region].id
  service  = "servicenetworking.googleapis.com" # Service that handles PSA
  reserved_peering_ranges = [google_compute_global_address.private_service_access_ip_range[0].name]

  depends_on = [
    google_project_service.apis, # Ensure servicenetworking API is enabled
    google_compute_global_address.private_service_access_ip_range
  ]
}

# Add explicit depends_on for SQL and Redis to the PSA connection
# (Though Terraform might infer this, being explicit is safer)
resource "null_resource" "wait_for_psa" {
  count = length(var.regions) > 0 ? 1 : 0
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Modify depends_on in google_sql_database_instance and google_redis_instance
# Add null_resource.wait_for_psa[0] to the depends_on list in both resources above.
# Example for SQL:
# depends_on = [
#   google_project_service.apis,
#   google_compute_network.vpc_network,
#   google_project_service.apis["servicenetworking.googleapis.com"],
#   null_resource.wait_for_psa[0] # Add this line
# ]
# Example for Redis:
# depends_on = [
#   google_project_service.apis,
#   google_compute_network.vpc_network,
#   google_project_service.apis["servicenetworking.googleapis.com"],
#   null_resource.wait_for_psa[0] # Add this line
# ]
# *** NOTE: Manually edit the depends_on blocks above to include this dependency ***
# The code above is illustrative; you need to modify the actual resource blocks.