#!/bin/bash

## Create the terraform bucket
gsutil mb gs://$1-terraform

## Save the state to the GCS bucket
touch backend.tf
rm -r backend.tf
echo 'terraform {
backend "gcs" {
bucket = "'$1'"
prefix = "'$2'/terraform/state"
}
}' >> backend.tf
