---
title: GCP Google Cloud Platform - Terraform Modules
description: Learn to use pre-built Terraform Modules from Terraform Registry
---

## Step-01: Introduction
- Learn to use pre-built Terraform Modules from [Terraform Registry](https://registry.terraform.io/browse/modules?provider=google)
- We are going to use the [VPC Terraform module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) from Terraform Registry in this demo

## Step-02: Review base Terraform Manifests
- **Folder:** 01-base-terraform-manifests
- This will create the following resources
  - VPC
  - Firewall Rules
  - VM Instance
- All the above resources will be created using Terraform Resources
- In the series of next steps, we will make necessary changes to use [Terraform VPC Module or network module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) from Terraform registry  

## Step-03: Folder: 02-terraform-manifests-with-modules
### Step-03-01: c4-vpc.tf
```hcl
# Module: VPC
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 9.1"
    project_id   = var.gcp_project
    network_name = "${local.name}-vpc"
    routing_mode = "GLOBAL"
    subnets = [
        {
            subnet_name           = "${local.name}-${var.gcp_region1}-subnet"
            subnet_ip             = "10.128.0.0/20"
            subnet_region         = var.gcp_region1
        }
    ] 
}
```

### Step-03-02: c7-outputs.tf
- Update VPC and Subnet Outputs
```hcl
# Terraform Output Values
output "vpc_id" {
  description = "VPC ID"
  #value = google_compute_network.myvpc.id 
  value = module.vpc.network_id
}
output "subnet_id" {
  description = "Subnet IDs"
  #value = google_compute_subnetwork.mysubnet.id   
  value = module.vpc.subnets_ids
}
```

### Step-03-03: c5-firewalls.tf
- Update VPC ID
```hcl
# Firewall Rule: SSH
resource "google_compute_firewall" "fw_ssh" {
  name = "${local.name}-fwrule-allow-ssh22"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  #network       = google_compute_network.myvpc.id 
  network = module.vpc.network_id
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
  #network       = google_compute_network.myvpc.id 
  network = module.vpc.network_id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver-tag"]
}
```

### Step-03-04: c6-vminstance.tf
- Update Subnet ID
```hcl
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = "${local.name}-myapp1"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  network_interface {
    #subnetwork = google_compute_subnetwork.mysubnet.id   
    subnetwork = module.vpc.subnets_ids[0]
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```

## Step-04: Execute Terraform Commands and Verify
```t
# Terraform Initialize
terraform init
Observation: 
1. Go to ".terraform/modules" folder and verify if module downloaded

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify
1. Verify VPC 
2. Verify Subnet
3. Verify Firewall Rules
4. Verify VM Instance
5. Access Application (http://<VM-EXTERNAL-IP>)
```

## Step-05: Clean-up
```t
# Terraform destroy
terraform destroy -auto-approve
```