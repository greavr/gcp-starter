# Create GKE Standard Cluster in each region
resource "google_container_cluster" "gke_cluster" {
  project                  = google_project.new_project.project_id
  for_each                 = var.regions
  name                     = "${each.key}-gke"
  location                 = each.value.name 
  remove_default_node_pool = true           
  initial_node_count       = 1              # Required, but we remove default pool anyway

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnet[each.key].id

  # Enable Cloud Operations for GKE (Logging, Monitoring)
  logging_service    = "logging.googleapis.com/kubernetes" 
  monitoring_service = "monitoring.googleapis.com/kubernetes" 

  # --- Disable Deletion Protection ---
  deletion_protection = false

  #Configure Private Cluster if needed
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Or true if control plane should only be private
    master_ipv4_cidr_block  = cidrsubnet("172.16.0.0/24", 4, index(keys(var.regions), each.key)+0) # Unique /28 range for master
  }

  # master_authorized_networks_config { # Restrict control plane access if public endpoint
  #   cidr_blocks {
  #     cidr_block   = "YOUR_MGMT_IP_RANGE/32"
  #     display_name = "Management Network"
  #   }
  # }

  release_channel { channel = "REGULAR" } # Or RAPID/REGULAR/STABLE

  depends_on = [
    google_project_service.apis,
    google_compute_subnetwork.subnet
  ]
}

# Create GKE Node Pool in each cluster/region
resource "google_container_node_pool" "primary_node_pool" {
  project    = google_project.new_project.project_id
  for_each   = var.regions
  name       = "${each.key}-${substr(var.gke_machine_type, 0, length(var.gke_machine_type) - 2)}"
  location   = each.value.name      
  cluster    = google_container_cluster.gke_cluster[each.key].name
  node_count = var.gke_node_count_per_zone 
  

  # Distribute nodes across specified zones in the region
  node_locations = each.value.gke_node_zones

  node_config {
    machine_type = var.gke_machine_type
    # Use the dedicated service account for nodes
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [ # Default scopes are usually sufficient with IAM roles
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # --- Shielded Instance Configuration ---
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true 
    }

    
    # Standard Logging & Monitoring Agent Config
    logging_variant = "DEFAULT"
    metadata = {
      disable-legacy-endpoints = "true"
    }
    # Add labels or taints if needed
    # labels = { ... }
    # taints = var.node_taints

    # Network tags can be crucial for firewall rules in private clusters
    tags = var.node_network_tags 

    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type
  }

  management {
    auto_repair  = true
    auto_upgrade = true 
  }

  # Configure Autoscaling
  autoscaling {
    min_node_count = var.gke_node_count_per_zone
    max_node_count = var.gke_max_node_count_per_zone
  }

  depends_on = [
    google_container_cluster.gke_cluster,
    google_service_account.gke_node_sa,
    google_project_iam_member.gke_node_sa_roles
  ]
}