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