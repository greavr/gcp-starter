#!/bin/bash
rm -rf ../automate-deploy/.terraform
rm -rf ../automate-deploy/.cleanup*
rm -rf ../automate-deploy/.terraform
rm ../automate-deploy/*.tfstate*
rm ../automate-deploy/.terraform.lock.hcl

rm -rf ../terraform/.terraform
rm -rf ../terraform/.cleanup*
rm -rf ../terraform/.terraform
rm ../terraform/*.tfstate*
rm ../terraform/.terraform.lock.hcl