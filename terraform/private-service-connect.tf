
# Note: The actual Private Service Access connection needs to be configured once per VPC.
# This often involves creating a global IP address range reservation.
# Terraform can manage this with `google_compute_global_address` and `google_service_networking_connection`.
# Adding that here for completeness:

resource "google_compute_global_address" "private_service_access_ip_range" {

  provider = google-beta
 
  project      = google_project.new_project.project_id
  name         = "${local.project_id}-psa-range"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"

  ip_version   = "IPV4"
  prefix_length= 16
  network      = google_compute_network.vpc_network.id

  depends_on = [google_compute_network.vpc_network]
}

resource "google_service_networking_connection" "private_vpc_connection" {

  provider = google-beta
  count    = length(var.regions) > 0 ? 1 : 0
  network  = google_compute_network.vpc_network.id
  service  = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_ip_range.name]

  depends_on = [
    google_project_service.apis, # Ensure servicenetworking API is enabled
    google_compute_global_address.private_service_access_ip_range
  ]
}

resource "null_resource" "wait_for_psa" {
  count = length(var.regions) > 0 ? 1 : 0
  depends_on = [google_service_networking_connection.private_vpc_connection]
}