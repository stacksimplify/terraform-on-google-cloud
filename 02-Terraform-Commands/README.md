---
title: GCP Google Cloud Platform - Terraform Commands
description: Learn Terraform Commands on Google Cloud
---

## Step-01: Introduction
- Understand basic Terraform Commands
  - terraform init
  - terraform validate
  - terraform plan
  - terraform apply
  - terraform destroy      

## Step-02: Terraform Core Commands
```t
# Configure GCP Credentials (ADC: Application Default Credentials)
gcloud auth application-default login

# Initialize Terraform
terraform init
Observation:
1) Initialized Local Backend
2) Downloaded the provider plugins (initialized plugins)
3) Review the folder structure ".terraform folder"

# Terraform Validate
terraform validate
Observation:
1) Tt performs a basic syntax check on your Terraform configuration files to ensure they are syntactically valid and internally consistent. 
2) It does not make any changes to the files themselves but verifies that the configuration is correct according to Terraform's rules.


# Terraform Plan to Verify what it is going to create / update / destroy
terraform plan
Observation:
1) Verify the plan
2) Verify the number of resources that going to get created
3) Plan Output: terraform plan generates an execution plan that shows what actions Terraform will take to achieve the desired state described in your configuration files. 
4) It will list resources to be created, updated, or destroyed.

# Terraform Apply
terraform apply 
[or]
terraform apply -auto-approve
Observations:
1) Will create resources on Google cloud
2) Will create terraform.tfstate file when you run the terraform apply command containing all the resource information. 
```

## Step-03: Verify the Resources created on Google Cloud
- Go to Google Cloud -> VPC Networks -> vpc1


## Step-04: Destroy Infrastructure
```t
# Destroy EC2 Instance
terraform destroy

# Delete Terraform files 
rm -rf .terraform*
rm -rf terraform.tfstate*
```

## Step-05: Conclusion
- Re-iterate what we have learned in this section
- Learned about Important Terraform Commands
  - terraform init
  - terraform validate
  - terraform plan
  - terraform apply
  - terraform destroy     

