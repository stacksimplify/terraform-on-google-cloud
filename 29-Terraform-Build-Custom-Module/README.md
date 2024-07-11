---
title: GCP Google Cloud Platform - Terraform Custom Modules
description: Learn to implement Terraform custom module
---

## Step-01: Introduction
- Build a simple Terraform Module for VM Instance which can be used in multiple environments like dev, qa, staging and prod


## Step-02: Review Terraform Manifests c1 to c5, tfvars file
- These are straight forward and same as previous demos
- c1-versions.tf
    - Update Terraform Settings Backend block: GCS bukcet
- c2-variables.tf
- c3-locals.tf
- c4-vpc.tf
- c5-firewalls.tf
- terraform.tfvars

## Step-03: Create Terraform VM Instance Module
### Step-03-01: Create folder structure
- **Folder Stucture:** "modules/vminstance"

### Step-03-02: versions.tf
```hcl
# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.36.0"
    }
  }
}
```

### Step-03-03: variables.tf
```hcl
# Input Variables
# GCP Project
variable "gcp_project" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = ""
}

# GCP Region
variable "gcp_region1" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = ""
}

# GCP Compute Engine Machine Type
variable "machine_type" {
  description = "Compute Engine Machine Type"
  type = string
  default = ""
}

variable "network" {
  description = "Network to deploy to. Only one of network or subnetwork should be specified."
  type        = string
  default     = ""
}

variable "subnetwork" {
  description = "Subnet to deploy to. Only one of network or subnetwork should be specified."
  type        = string
  default     = ""
}

variable "zone" {
  type        = string
  description = "Zone where the instances should be created. If not specified, instances will be spread across available zones in the region."
  default     = null
}

variable "vminstance_name" {
  type        = string
  description = "VM Instance Name"
  default     = ""
}

variable "firewall_tags" {
  description = "List of firewall tags"
  type        = list(string)
}
```

### Step-03-04: main.tf
```hcl
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = var.vminstance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.firewall_tags
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size = 10
      #size = 20
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  network_interface {
    subnetwork = var.subnetwork   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```

### Step-03-05: outputs.tf
```hcl
output "vm_external_ip" {
  description = "VM External IPs"
  value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
}
```

## Step-04: Call the Terraform Module in c6-vminstance.tf 
```hcl
# Module Block: Create a single Compute Engine instance
module "myvminstance" {
  source  = "../modules/vminstance"
  vminstance_name = "${local.name}-myapp1"
  machine_type = var.machine_type
  zone = "us-central1-a"
  firewall_tags = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
  subnetwork = google_compute_subnetwork.mysubnet.id
}
```

## Step-05: c7-outputs.tf
```hcl
# Terraform Output Values
output "vpc_id" {
  description = "VPC ID"
  value = google_compute_network.myvpc.id 
}
output "subnet_id" {
  description = "Subnet ID"
  value = google_compute_subnetwork.mysubnet.id   
}
output "vm_external_ip" {
  description = "VM External IPs"
  #value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
  value = module.myvminstance.vm_external_ip
}
```

## Step-06: Execute Terraform Commands and Verify
```t
# Change Directory
cd terraform-manifests

# Terraform Initialize
terraform init
Observation:
1. Review if module downloaded to ".terraform/modules/modules.json" file

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify Resources
1. VM Instance
2. Access Application
3. Review VM Instance disk size, it should be 10GB
```

## Step-07: Make a change in the VM Instance module
```t
# Change VM Instance Disk size from size 10 to size 20 in Terraform Module
1. Go to File: modules/vminstance/main.tf
2. Change size from 10GB to 20GB in boot_disk block

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      #size = 10
      size = 20
    }
  }
```

## Step-08: Execute Terraform Commands and Verify
```t
# Change Directory
cd terraform-manifests

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify Resources
1. VM Instance
2. Access Application
3. Review VM Instance disk size, it should be 20GB
```

## Step-09: Clean-up
```t
# Change Directory
cd terraform-manifests

# Terraform Destroy
terraform destroy -auto-approve
```

## Step-10: Rollback the change: To be demo ready for students
```t
# Change VM Instance Disk size from size 20 to size 10 in Terraform Module
1. Go to File: modules/vminstance/main.tf
2. Change size from 20GB to 10GB in boot_disk block

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size = 10
      #size = 20
    }
```