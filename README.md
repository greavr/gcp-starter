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

# What is deployed

This terraform will deploy the following resources:

* **Create a Custom VPC Network:**
    * Set the **Routing mode** to `Global`.
    * [Documentation: VPC Networks](https://cloud.google.com/vpc/docs/vpc)
* **Define Subnets:** Create subnets within the VPC for the specified regions and zones. Use an appropriate IP CIDR range for each subnet, ensuring they don't overlap.
    * **Region `us-east1`:**
        * Subnet 1: Zone `us-east1-b`
        * Subnet 2: Zone `us-east1-c`
        * Subnet 3: Zone `us-east1-d`
    * **Region `us-west2`:**
        * Subnet 1: Zone `us-west2-a`
        * Subnet 2: Zone `us-west2-b`
        * Subnet 3: Zone `us-west2-c`
    * [Documentation: Subnets](https://cloud.google.com/vpc/docs/subnets)

* **Configure Private Services Access:** Set up a private connection from your VPC to Google-managed services (like Cloud SQL and Memorystore). This involves allocating an IP range within your VPC for these services.
    * [Documentation: Private Services Access](https://cloud.google.com/vpc/docs/private-services-access)

* **Create GCS Buckets:**
    * Bucket 1: Location set to `us-east1` (regional).
    * Bucket 2: Location set to `us-west2` (regional).
    * Choose appropriate storage classes and access controls based on your needs.
* [Documentation: Cloud Storage](https://cloud.google.com/storage/docs)
* [Documentation: Creating Buckets](https://cloud.google.com/storage/docs/creating-buckets)

* **Create a Docker Repository:**
    * Create one **standard** Docker repository in your primary region (e.g., `us-east1`).
    * Format: Docker
    * Mode: Standard
    * Location: `us-east1`
* **Regional Access/Caching:** Artifact Registry provides regional endpoints (e.g., `us-west2-docker.pkg.dev`). When clients in other regions (like `us-west2`) pull images from the primary repository using their local regional endpoint, Artifact Registry transparently caches images closer to the client, improving performance. No separate "virtual replica" repository is needed for this caching behaviour within GCP.
* [Documentation: Artifact Registry](https://cloud.google.com/artifact-registry/docs)
* [Documentation: Docker Repositories](https://cloud.google.com/artifact-registry/docs/docker/store-docker-images)

* **Create Private GKE Clusters:**
    * Cluster 1: Region `us-east1`
    * Cluster 2: Region `us-west2`
    * Ensure clusters are configured as **Private Clusters**. This means nodes only have internal IP addresses, and you configure authorized networks or private endpoint access for the control plane.
    * [Documentation: Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs)
    * [Documentation: Creating Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
* **Node Pools:**
    * Each cluster should have at least one default node pool configured. Define machine types and sizes according to application needs.
* **Custom Service Account:**
    * Create a dedicated IAM Service Account for the GKE nodes in each cluster (e.g., `gke-node-sa@<project-id>.iam.gserviceaccount.com`).
    * Grant this service account the minimum required IAM roles (e.g., `roles/monitoring.viewer`, `roles/logging.logWriter`, `roles/storage.objectViewer`).
    * Configure the node pools to use this custom service account instead of the default Compute Engine service account for improved security (least privilege).
    * [Documentation: Using Least Privilege IAM Service Accounts for Nodes](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa)

* **Create Memorystore for Redis Instances:**
    * Instance 1: Region `us-east1`
    * Instance 2: Region `us-west2`
    * Tier: **Standard** (for High Availability - HA).
    * Network: Select the configured VPC network. Private Services Access must be configured.
    * [Documentation: Memorystore for Redis](https://cloud.google.com/memorystore/docs/redis)
    * [Documentation: Redis High Availability](https://cloud.google.com/memorystore/docs/redis/high-availability)

* **Create Cloud SQL for PostgreSQL Instances:**
    * Instance 1: Region `us-east1`
    * Instance 2: Region `us-west2`
    * Database version: PostgreSQL (select desired version).
    * Enable **High Availability (HA)**.
    * Connectivity: Enable **Private IP**. Select the configured VPC network. Private Services Access must be configured.
    * [Documentation: Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
    * [Documentation: Cloud SQL High Availability](https://cloud.google.com/sql/docs/postgres/high-availability)
    * [Documentation: Configuring Private IP](https://cloud.google.com/sql/docs/postgres/configure-private-ip)


## Configuration

1.  **Clone the Repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory>/terraform
    ```

2.  **Create a Variables File:** Terraform loads variables from files named `terraform.tfvars` or `*.auto.tfvars` automatically. Create a file named `terraform.tfvars` in the root of the repository.

3.  **Define Required Variables:** Add the following *required* variables to your `terraform.tfvars` file:

    ```terraform
    # terraform.tfvars

    # REQUIRED: Specify your GCP Organization ID
    org_id = "YOUR_ORGANIZATION_ID" # e.g., "123456789012"

    # REQUIRED: Specify the Billing Account ID
    # SECURITY NOTE: This is sensitive. Consider using environment variables
    # (export TF_VAR_billing_account="012345-67890A-BCDEF1") instead of committing this file.
    billing_account = "YOUR_BILLING_ACCOUNT_ID" # e.g., "012345-67890A-BCDEF1"

    # OPTIONAL but recommended for Assured Workloads:
    # Specify the Folder ID if using a pre-configured Assured Workloads folder.
    # If omitted or null, the project will be created directly under the org_id.
    # assured_workloads_folder_id = "folders/YOUR_FOLDER_ID" # e.g., "folders/9876543210"
    ```

4.  **Customize Optional Variables (Optional):** Review the `variables.tf` file. You can override any default values by adding them to your `terraform.tfvars` file. Examples:

    ```terraform
    # terraform.tfvars (continued)

    # --- Example Overrides ---

    # Change the prefix for the generated project ID
    project_id_prefix = "mycompany-prod-"

    # Use a different primary region (must be defined in the 'regions' map)
    # primary_region = "us-west2"

    # Customize GKE node settings
    # gke_machine_type = "e2-standard-8"
    # gke_node_count_per_zone = 2

    # Customize Cloud SQL settings
    # postgres_version = "POSTGRES_16"
    # db_machine_type  = "db-custom-2-7680" # 2 vCPU, 7.5 GB RAM

    # Customize Firestore location (ensure compliance if using Assured Workloads)
    # firestore_location = "nam5" # Multi-region example
    ```

## Usage

1.  **Initialize Terraform:** Download necessary provider plugins.
    ```bash
    terraform init
    ```

2.  **Plan Changes:** Review the resources Terraform will create or modify. If you didn't name your variables file `terraform.tfvars`, use the `-var-file` flag.
    ```bash
    terraform plan # Reads terraform.tfvars automatically
    # or
    # terraform plan -var-file="my-vars.tfvars"
    ```

3.  **Apply Changes:** Create the infrastructure. You will be prompted to confirm unless you use `-auto-approve`.
    ```bash
    terraform apply # Reads terraform.tfvars automatically
    # or
    # terraform apply -var-file="my-vars.tfvars"

    # To skip confirmation (use with caution):
    # terraform apply -auto-approve
    ```

    Terraform will output useful information, such as the created project ID, GKE cluster details, database names, etc.

## Destroying Resources

To tear down the infrastructure created by Terraform:

1.  **Plan Destruction:** See what will be destroyed.
    ```bash
    terraform plan -destroy # Reads terraform.tfvars automatically
    # or
    # terraform plan -destroy -var-file="my-vars.tfvars"
    ```
2.  **Destroy:** Remove all managed resources. **This is irreversible.**
    ```bash
    terraform destroy # Reads terraform.tfvars automatically
    # or
    # terraform destroy -var-file="my-vars.tfvars"

    # To skip confirmation (use with caution):
    # terraform destroy -auto-approve
    ```

## Important Notes

* **Billing:** Ensure the `billing_account` provided is active and has sufficient credits/limits. You are responsible for all costs incurred.
* **Security:** Do **not** commit `terraform.tfvars` files containing sensitive information like `billing_account` directly to your Git repository if it's public or shared widely. Use environment variables (`export TF_VAR_billing_account=...`) or a secure secrets management system for CI/CD pipelines.
* **Assured Workloads:** If using `assured_workloads_folder_id`, ensure the chosen regions (`regions` variable) and service locations (`firestore_location`) comply with the requirements of that specific Assured Workloads environment (e.g., FedRAMP, IL4, HIPAA).
* **API Enablement:** Terraform attempts to enable necessary GCP APIs. This can sometimes take a few minutes. If you encounter API-related errors on the first run, waiting a few minutes and running `terraform apply` again might resolve the issue.
* **Project ID:** A rand