# ----------------------------------------------------------------------------------------------------------------------
# Base Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "org_id" {
  description = "The numeric Organization ID where the project will be created."
  type        = string
}

variable "billing_account_id" {
  description = "The ID of the Billing Account to associate the new project with (e.g., '012345-67890A-BCDEF0')."
  type        = string
}

variable "new_project_id" {
  description = "The desired globally unique ID for the new project."
  type        = string
}

variable "new_project_name" {
  description = "The display name for the new project."
  type        = string
  default     = null # Defaults to new_project_id if not set
}

variable "new_project_folder_id" {
  description = "Optional: The numeric Folder ID (e.g., 'folders/12345') to create the project within."
  type        = string
  default     = null
}

# ----------------------------------------------------------------------------------------------------------------------
# GCS Base Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "gcs_bucket_location" {
  description = "The location for the new GCS bucket (e.g., 'US-CENTRAL1')."
  type        = string
  default     = "US-EAST1"
}

variable "gcs_storage_name" {
  description = "GCS Storage Bucket Name Append"
  type        = string
  default     = "terraform"
}

# ----------------------------------------------------------------------------------------------------------------------
# Artifact Repository Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "artifact_registry_location" {
  description = "The location for the new Artifact Registry repository (e.g., 'us-central1')."
  type        = string
  default     = "us-east1"
}

variable "artifact_registry_repo_id" {
  description = "The desired ID for the Artifact Registry repository within the project."
  type        = string
  default     = "cloud-build-artifacts"
}

# ----------------------------------------------------------------------------------------------------------------------
# Cloud Bild Variables
# ----------------------------------------------------------------------------------------------------------------------
variable "custom_sa_id" {
  description = "The desired account ID for the custom Cloud Build service account (e.g., 'cloud-build-sa')."
  type        = string
  default     = "terraform-deploy-sa"
}

variable "custom_sa_display_name" {
  description = "The display name for the custom Cloud Build service account."
  type        = string
  default     = "Custom SA to deploy from terraform"
}

variable "apis_to_enable" {
  description = "List of APIs to enable on the new project."
  type        = list(string)
  default = [
    "serviceusage.googleapis.com",         
    "cloudresourcemanager.googleapis.com", 
    "iam.googleapis.com",                  
    "cloudbuild.googleapis.com",         
    "artifactregistry.googleapis.com",   
    "storage.googleapis.com",       
    "secretmanager.googleapis.com",
  ]
}