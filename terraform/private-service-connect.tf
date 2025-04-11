
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