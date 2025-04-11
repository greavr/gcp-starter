# Create VPC Network for each region
resource "google_compute_network" "vpc_network" {
  project      = google_project.new_project.project_id
  
  name                    = "${local.project_id}-vpc"
  auto_create_subnetworks = false # We will create custom subnets
  mtu                     = 1460  # Standard MTU

  depends_on = [google_project_service.apis]
}

# Create Subnetwork in each VPC/Region
resource "google_compute_subnetwork" "subnet" {
  project                  = google_project.new_project.project_id
  for_each                 = var.regions
  name                     = "${each.key}-subnet"
  ip_cidr_range            = cidrsubnet("10.0.0.0/16", 8, index(keys(var.regions), each.key)) # Assign non-overlapping /24 ranges like 10.0.0.0/24, 10.0.1.0/24 etc.
  region                   = each.key
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true # Allows VMs without external IPs to reach Google APIs

  depends_on = [google_compute_network.vpc_network]
}
