terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.29" # Updated version potentially needed for AW/VPN features
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "google" {
  # Credentials sourced automatically
}

provider "google-beta" {
  # Credentials sourced automatically
}

# Generate a random suffix for the project ID
resource "random_id" "project_suffix" {
  byte_length = 4
}

# Construct the full project ID
locals {
  project_id = "${var.project_id_prefix}-${random_id.project_suffix.hex}"
}