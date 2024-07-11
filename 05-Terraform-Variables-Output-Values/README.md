---
title: GCP Google Cloud Platform - Terraform Input Variables and Output Values
description: Learn Terraform Input Variables and Output Values on Google Cloud Platform
---
## Step-01: Introduction
### Terraform Concepts
- Terraform Input Variables
- Terraform Output Values

### What are we going to learn ?
1. Learn about Terraform `Input Variable` basics
  - gcp_project
  - gcp_region
  - machine_type
2. Learn about Terraform `Output Values`
  - vm_instanceid
  - vm_selflink
  - vm_id
  - vm_name
  - vm_machine_type


## Step-02: c2-variables.tf - Define Input Variables in Terraform
- [Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html)
```hcl
# GCP Project
variable "gcp_project" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = "gcplearn9"
}

# GCP Region
variable "gcp_region" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = "us-central1"
}

# GCP Compute Engine Machine Type
variable "machine_type" {
  description = "Compute Engine Machine Type"
  type = string
  default = "e2-micro"
}
```

## Step-03: Reference the variables in respective `.tf`fies
```hcl
# c1-versions.tf
provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}

# c3-vpc.tf
resource "google_compute_subnetwork" "mysubnet" {
  name = "${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/20"
  network = google_compute_network.myvpc.id 
}

# c5-vminstance.tf
resource "google_compute_instance" "myvm" {
  name         = "myvm1"
  machine_type = var.machine_type
  zone         = var.gcp_region1
```

## Step-04: Variable Definition Option: terraform.tfvars
- We can define the variables 
```t
# terraform.tfvars
gcp_project   = "gcplearn9"
gcp_region1   = "us-central1"
machine_type  = "e2-micro"

# Execute Terraform Commands
# Terraform Init
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan
Observation:
1. Review VM Instance machine_type
2. It should be loaded from terraform.tfvars
```

## Step-06: Variable Definition Option: vm.auto.tfvars
```t
# vm.auto.tfvars
machine_type  = "e2-medium"

# Terraform Plan
terraform plan
Observation:
1. Review VM Instance machine_type
2. It should be loaded from vm.auto.tfvars
3. So, so far we have seen three ways
3.1 vm.auto.tfvars - First Priority
3.2 terraform.tfvars - Second Priority
3.3 variables.tf - default value defined in variables.tf
```

## Step-07: Variable Definition Option: vm.tfvars
```t
# vm.tfvars
machine_type  = "e2-standard-8"

# Terraform Plan
terraform plan
Observation:
1. Review VM Instance machine_type
2. It should be loaded from vm.auto.tfvars
3. We need to explicity pass the vm.tfvars to terraform commands

# Terraform plan
terraform plan --var-file=vm.tfvars
Observation:
1. Review VM Instance machine_type
2. It should be loaded from vm.tfvars whose value is e2-standard-8
3. In short, what-ever we pass via --var-file or --var flags will be having higher priority than anyother options
```

## Step-07: Variable Definition Option: Directly pass it in command
```t
# Terraform plan
terraform plan --var=machine_type=e2-standard-4
Observation:
1. Review VM Instance machine_type
2. It should be loaded from the command whose value is e2-standard-4
```

## Step-08: Comment values in vm.auto.tfvars and vm.tfvars
- We will use **machine_type  = "e2-micro"** from **terraform.tfvars** going forward.
- We have created other two files just to learn the multiple options available
```t
# vm.auto.tfvars
# machine_type  = "e2-medium"

# vm.tfvars
# machine_type  = "e2-standard-2"
```

## Step-09: Input Variables as Environment Variables (Unix or Linux Environments)
```t
# Comment machine_type in terraform.tfvars
#machine_type  = "e2-micro"

# Set Environment Variable
export TF_VAR_machine_type="e2-standard-2"
echo $TF_VAR_machine_type

# Run Terraform Plan
terraform plan
Observation: Machine type configured will be "e2-standard-2" from environment variable set

# Unset Environment variable
unset TF_VAR_machine_type
echo $TF_VAR_machine_type

# Run Terraform Plan
terraform plan
Observation: Machine type configured will be "e2-small" from variables.tf default value

# Variable Precendence
Priority-1: Any -var and -var-file options on the command line, in the order they are provided. 
Priority-2: Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
Priority-3: The terraform.tfvars.json file, if present.
Priority-4: The terraform.tfvars file, if present.
Priority-5: Environment variables

# Comment machine_type in terraform.tfvars
machine_type  = "e2-micro"
```

## Step-10: c6-output-values.tf - Define Output Values 
- [Output Values](https://www.terraform.io/docs/language/values/outputs.html)
```hcl
# Terraform Output Values
## ATTRIBUTES
output "vm_instanceid" {
  description = "VM Instance ID"
  value = google_compute_instance.myapp1.instance_id
}

output "vm_selflink" {
  description = "VM Instance Self link"
  value = google_compute_instance.myapp1.self_link
}

output "vm_id" {
  description = "VM ID"
  value = google_compute_instance.myapp1.id
}

output "vm_external_ip" {
  description = "VM External IPs"
  value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
}

## ARGUMENTS
output "vm_name" {
  description = "VM Name"
  value = google_compute_instance.myapp1.name
}

output "vm_machine_type" {
  description = "VM Machine Type"
  value = google_compute_instance.myapp1.machine_type
}
```

## Step-11: Execute Terraform Commands
```t
# Terraform Initialize
terraform init
Observation:
1) Initialized Local Backend
2) Downloaded the provider plugins (initialized plugins)
3) Review the folder structure ".terraform folder"

# Terraform Validate
terraform validate
Observation:
1) If any changes to files, those will come as printed in stdout (those file names will be printed in CLI)

# Terraform Plan
terraform plan
1) Verify the number of resources that going to get created
2) Verify the variable replacements worked as expected

# Terraform Apply
terraform apply 
[or]
terraform apply -auto-approve
Observations:
1) Create resources on cloud
2) Created terraform.tfstate file when you run the terraform apply command
```

## Step-12: Access Application
```t
# Access index.html
http://<EXTERNAL-IP>/index.html
http://<EXTERNAL-IP>/app1/index.html
```

## Step-13: Clean-Up
```t
# Terraform Destroy
terraform plan -destroy  # You can view destroy plan using this command
terraform destroy

# Clean-Up Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```
  