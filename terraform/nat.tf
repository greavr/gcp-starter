locals {
  region_list    = keys(var.regions)
}

resource "google_compute_router" "regional_routers" {
    project      = google_project.new_project.project_id

    count = var.enable_regional_nat ? length(local.region_list) : 0
    name    = "${local.region_list[count.index]}-router"
    network = google_compute_network.vpc_network.id
    region  = local.region_list[count.index]

    bgp {
        asn = 64514
    }

    depends_on = [ google_compute_network.vpc_network ]
}

resource "google_compute_router_nat" "nat_gateway" {
    count = var.enable_regional_nat ? length(local.region_list) : 0

    project                            = google_project.new_project.project_id
    name                               = "${local.region_list[count.index]}-nat"
    router                             = google_compute_router.regional_routers[count.index].name
    region                             = google_compute_router.regional_routers[count.index].region

    nat_ip_allocate_option             = "AUTO_ONLY"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

    subnetwork {
        name                    = google_compute_subnetwork.subnet[local.region_list[count.index]].id
        source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
    }

    depends_on = [ google_compute_router.regional_routers ]
}
