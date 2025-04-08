output "project_id" {
  description = "The ID of the created Google Cloud project."
  value       = google_project.new_project.project_id
}

output "gke_cluster_endpoints" {
  description = "Endpoint addresses for the GKE clusters."
  value = { for k, cluster in google_container_cluster.gke_cluster : k => cluster.endpoint }
  sensitive   = true
}

output "gke_cluster_ca_certificates" {
  description = "CA certificates for the GKE clusters."
  value = { for k, cluster in google_container_cluster.gke_cluster : k => cluster.master_auth[0].cluster_ca_certificate }
  sensitive   = true
}

output "gke_node_service_account_email" {
  description = "Email of the service account used by GKE nodes."
  value       = google_service_account.gke_node_sa.email
}

output "storage_bucket_names" {
  description = "Names of the created Cloud Storage buckets."
  value = { for k, bucket in google_storage_bucket.bucket : k => bucket.name }
}

output "cloud_sql_instance_connection_names" {
  description = "Connection names for the Cloud SQL PostgreSQL instances (used by Cloud SQL Proxy)."
  value = { for k, instance in google_sql_database_instance.postgres_ha : k => instance.connection_name }
}

output "cloud_sql_instance_private_ip_addresses" {
  description = "Private IP addresses for the Cloud SQL PostgreSQL instances."
  value = { for k, instance in google_sql_database_instance.postgres_ha : k => instance.private_ip_address }
   sensitive   = true
}

output "redis_instance_host_ips" {
  description = "Host IPs for the Cloud Memorystore Redis instances (primary node)."
  value = { for k, instance in google_redis_instance.redis_ha : k => instance.host }
  sensitive   = true
}

output "artifact_registry_primary_repo_name" {
  description = "Full name of the primary Artifact Registry repository."
  value       = google_artifact_registry_repository.primary_repo.name
}

output "artifact_registry_mirror_repo_names" {
  description = "Full names of the mirror Artifact Registry repositories."
  value       = { for k, repo in google_artifact_registry_repository.mirror_repo : k => repo.name }
}

# REMOVED: postgres_root_password output
# output "postgres_root_password" { ... }

# --- HA VPN Outputs ---
# (VPN outputs remain the same as before)

output "gcp_ha_vpn_gateway_ips" {
  description = "Public IP addresses of the GCP HA VPN Gateway interfaces (Use these for AWS Customer Gateway configuration)."
  value = {
    for k, gw in google_compute_ha_vpn_gateway.gcp_ha_gateway : k => {
      interface_0 = gw.vpn_interfaces[0].ip_address
      interface_1 = gw.vpn_interfaces[1].ip_address
    }
  }
}

output "vpn_tunnel_shared_secrets" {
  description = "Generated shared secrets for each VPN tunnel (Use these for AWS VPN Connection configuration)."
  value = {
    for k, secret in random_password.vpn_shared_secret : k => secret.result
  }
  sensitive = true
}

output "vpn_tunnel_names_and_bgp_ips" {
  description = "Mapping of GCP VPN tunnel names to their BGP interface IPs."
  value = {
    for k, tunnel in google_compute_vpn_tunnel.tunnel : tunnel.name => {
      gcp_bgp_ip = google_compute_router_interface.router_interface[k].ip_range
      aws_bgp_ip = google_compute_router_peer.bgp_peer[k].peer_ip_address
      region     = tunnel.region
    }
  }
}