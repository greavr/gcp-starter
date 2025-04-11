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
      private_network = google_compute_network.vpc_network.id
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