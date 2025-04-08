# gcp-starter
Sample GCP Starter Terraform

# Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

# Environment Setup
* Install tools
* Run the following commands to login to gcloud:
```
gcloud auth login
gcloud auth application-default login
```

This will setup your permissions for terraform to run.

# Deploy guide
```
cd terraform
terraform init
terraform plan
terraform apply
```