---
title: GCP Google Cloud Platform - Terraform Datasources
description: Learn Terraform Datasources on Google Cloud Platform
---

## Step-01: Introduction
- Learn [Terraform Local Values](https://developer.hashicorp.com/terraform/language/values/locals)
- [GCP Instance Templates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_template)
- [Terraform Datasource to get VM Image Information](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)

## Step-02: c2-01-variables.tf
```hcl
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}

# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "sap"
}
```

## Step-03: c2-02-local-values.tf
```hcl
# Define Local Values in Terraform
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
} 
```

## Step-04: terraform.tfvars
```hcl
gcp_project     = "gcplearn9"
gcp_region1     = "us-central1"
machine_type    = "e2-micro"
environment     = "dev"
business_divsion = "hr"
```

## Step-06: c3-vpc.tf
- Update **name** attribute
```hcl
# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}
```

## Step-07: c4-firewalls.tf
- Update **name** attribute
```hcl
# Firewall Rule: SSH
resource "google_compute_firewall" "fw_ssh" {
  name = "${local.name}-fwrule-allow-ssh22"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.myvpc.id 
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-tag"]
}

# Firewall Rule: HTTP Port 80
resource "google_compute_firewall" "fw_http" {
  name = "${local.name}-fwrule-allow-http80"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.myvpc.id 
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver-tag"]
}
```

## Step-08: c5-datasource.tf
- [Terraform Datasource to get VM Image Information](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)
```hcl
# Datasource: Get information about a Google Compute Image
data "google_compute_image" "my_image" {
  #Debian
  project = "debian-cloud"  
  family  = "debian-12"
  
  # CentOs
  #project = "centos-cloud"  
  #family  = "centos-stream-9"

  # RedHat
  #project = "rhel-cloud" 
  #family  = "rhel-9"
  
  # Ubuntu
  #project = "ubuntu-os-cloud"
  #family  = "ubuntu-2004-lts"

  # Microsoft
  #project = "windows-cloud"
  #family  = "windows-2022"

  # Rocky Linux
  #project = "rocky-linux-cloud"
  #family  = "rocky-linux-8"
}


# Outputs
output "vmimage_project" {
  value = data.google_compute_image.my_image.project
}

output "vmimage_family" {
  value = data.google_compute_image.my_image.family
}

output "vmimage_name" {
  value = data.google_compute_image.my_image.name
}

output "vmimage_image_id" {
  value = data.google_compute_image.my_image.image_id
}

output "vmimage_status" {
  value = data.google_compute_image.my_image.status
}

output "vmimage_id" {
  value = data.google_compute_image.my_image.id
}

output "vmimage_self_link" {
  value = data.google_compute_image.my_image.self_link
}

output "vmimage_info" {
  value = {
    project  = data.google_compute_image.my_image.project
    family   = data.google_compute_image.my_image.family
    name     = data.google_compute_image.my_image.name
    image_id = data.google_compute_image.my_image.image_id
    status   = data.google_compute_image.my_image.status
    id       = data.google_compute_image.my_image.id
    self_link = data.google_compute_image.my_image.self_link
  }
}
```

## Step-09: c6-01-app1-instance-template.tf
- [GCP Instance Templates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_template)
```hcl
# Google Compute Engine: Regional Instance Template
resource "google_compute_region_instance_template" "myapp1" {
  name        = "${local.name}-myapp1-template"
  description = "This template is used to create MyApp1 server instances."
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
  instance_description = "MyApp1 VM Instances"
  machine_type         = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  # Create a new boot disk from an image
  disk {
    #source_image      = "debian-cloud/debian-12"
    source_image      = data.google_compute_image.my_image.self_link
    auto_delete       = true
    boot              = true
  }
  # Network Info
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id 
    access_config {
      # Include this section to give the VM an external IP address
    }  
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")

  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}
```

## Step-10: c6-02-vminstance.tf
```hcl
# Resource Block: Create a Compute Engine VM instance
resource "google_compute_instance_from_template" "myapp1" {
 # Meta-Argument: for_each
  for_each = toset(data.google_compute_zones.available.names)
  name         = "${local.name}-myapp1-vm-${each.key}"  
  zone        = each.key # You can also use each.value because for list items each.key == each.value
  source_instance_template = google_compute_region_instance_template.myapp1.self_link
}
```

## Step-11: c6-03-vminstance-outputs.tf
```hcl
# Terraform Output Values
# Output - For with list
output "instance_names" {
  description = "VM Instance Names"
  value = [for instance in google_compute_instance_from_template.myapp1: instance.name]
}

# Output - For Loop with Map 
output "vm_instance_ids" {
  description = "VM Instances Names -> VM Instance IDs"
  value = {for instance in google_compute_instance_from_template.myapp1: instance.name => instance.instance_id}
}

output "vm_external_ips" {
  description = "VM Instance Names -> VM External IPs"
  value = {for instance in google_compute_instance_from_template.myapp1: instance.name => instance.network_interface.0.access_config.0.nat_ip}
}
```

## Step-12: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply
```

# Step-13: Verify VM Instances
- Go to Google Cloud -> Compute Engine -> VM Instances
- **Observation:** VM Instances will be created in  all avaliable zones in a region

## Step-14: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```

