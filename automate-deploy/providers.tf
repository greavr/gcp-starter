terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" 
    }
  }
}

provider "google" {
  # Credentials sourced automatically
}

provider "google-beta" {
  # Credentials sourced automatically
}