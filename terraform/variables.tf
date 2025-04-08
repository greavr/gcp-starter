# ----------------------------------------------------------------------------------------------------------------------
# Base Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "project_id_prefix" {
  description = "A prefix to use for the new project ID. A random suffix will be appended."
  type        = string
  default     = "ppx-gcp-" # Updated default
}

variable "billing_account" {
  description = "The Billing Account ID to associate the new project with."
  type        = string
  # Sensitive - Consider using TF_VAR_billing_account environment variable or terraform.tfvars
}

variable "org_id" {
  description = "The Organization ID where the Assured Workloads folder exists and the project will be created."
  type        = string
  # This is now mandatory for Assured Workloads folder association
}

variable "assured_workloads_folder_id" {
  description = "The Folder ID of the pre-configured Assured Workloads environment (e.g., 'folders/123456789')."
  type        = string
  # Mandatory - Obtain this from your GCP Organization console
}

variable "regions" {
  description = "Map of regions where resources will be deployed."
  type        = map(object({
    name          = string
    gke_node_zones = list(string) # Specify zones within the region for GKE nodes
  }))
  default = {
    "us-east1" = {
      name          = "us-east1"
      gke_node_zones = ["us-east1-b", "us-east1-c", "us-east1-d"]
    }
    "me-central2" = {
      name          = "me-central2"
      gke_node_zones = ["me-central2-a", "me-central2-b", "me-central2-c"]
    }
  }
}

variable "primary_region" {
  description = "The primary region for resources like Firestore and the main Artifact Registry."
  type        = string
  default     = "us-east1"
  validation {
    condition     = contains(keys(var.regions), var.primary_region)
    error_message = "The primary_region must be one of the keys defined in the 'regions' variable."
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# GKE Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "gke_machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
  default     = "e2-standard-4"
}

variable "gke_node_count_per_zone" {
  description = "Number of GKE nodes per zone in the node pool."
  type        = number
  default     = 1
}

variable "gke_max_node_count_per_zone" {
  description = "Max Number of GKE nodes per zone in the node pool."
  type        = number
  default     = 3
}


# ----------------------------------------------------------------------------------------------------------------------
# GCS Base Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "gcs_storage_name" {
  description = "GCS Storage Bucket Name"
  type        = string
  default     = "${local.project_id}-gcs"
}


# ----------------------------------------------------------------------------------------------------------------------
# Cloud SQL Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "postgres_version" {
  description = "Which version of PostgreSQL would you like to run"
  type        = string
  default     = "POSTGRES_15" # Or POSTGRES_14, etc. Choose desired version
}

variable "db_machine_type" {
  description = "Machine type for Cloud SQL PostgreSQL instances (e.g., db-custom-2-7680)."
  type        = string
  default     = "db-f1-micro" # Choose a production-suitable tier
}

variable "db_disk_size" {
  description = "Starting size, willl grow automatically"
  type        = number
  default     = 20
}

# ----------------------------------------------------------------------------------------------------------------------
# MemoryStore (Redis) Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "redis_tier" {
  description = "Tier for Cloud Memorystore Redis instances (BASIC or STANDARD_HA)."
  type        = string
  default     = "STANDARD_HA"
}

variable "redis_memory_size_gb" {
  description = "Memory capacity for Redis instances in GB."
  type        = number
  default     = 1
}

# ----------------------------------------------------------------------------------------------------------------------
# Firestore Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "firestore_location" {
  description = "Location for Firestore database. Choose a multi-region (nam5, eur3) or a region matching primary_region. Ensure it complies with Assured Workloads requirements."
  type        = string
  default     = "us-east1" # Verify this location is allowed by your Assured Workloads compliance regime
}

# ----------------------------------------------------------------------------------------------------------------------
# Artifact Repository
# ----------------------------------------------------------------------------------------------------------------------
variable "artifact_repo_format" {
  description = "Format for the Artifact Registry repositories (e.g., DOCKER, MAVEN, NPM)."
  type        = string
  default     = "DOCKER"
}
