---
title: GCP Google Cloud Platform - Terraform Settings, Providers and Resource Blocks
description: Learn Terraform Settings, Providers and Resource Blocks on Google Cloud Platform
---

## Step-01: Introduction
- [Terraform Settings](https://www.terraform.io/docs/language/settings/index.html)
- [Terraform Providers](https://www.terraform.io/docs/providers/index.html)
- [Terraform Resources](https://www.terraform.io/docs/language/resources/index.html)
- [Terraform File Function](https://www.terraform.io/docs/language/functions/file.html)
- [Terraform tolist() Function](https://developer.hashicorp.com/terraform/language/functions/tolist)
- [Terraform State Basics](https://developer.hashicorp.com/terraform/language/state)
- Create **Compute Engine VM Instance** using Terraform and provision a webserver with Startup script. 

## Step-02: In c1-versions.tf - Create Terraform Settings Block
- Understand about [Terraform Settings Block](https://www.terraform.io/docs/language/settings/index.html) and create it
```t
# Terraform Settings Block
terraform {
  required_version = ">= 1.8"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.32.0"
    }
  }
}
```

## Step-03: In c1-versions.tf - Create Terraform Providers Block 
- Understand about [Terraform Providers](https://www.terraform.io/docs/providers/index.html)
- Create [Google Cloud Providers Block](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
```t
# Provider Block
provider "google" {
  project     = "gcplearn9"
  region      = "us-central1"
}
```

## Step-04: Resource Block: c3-vpc.tf 
- Understand about [Resources](https://www.terraform.io/docs/language/resources/index.html)
- Create [VPC](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
- Create [SUBNET](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
```t
# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "vpc1"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name = "subnet1"
  region = "us-central1"
  ip_cidr_range = "10.128.0.0/20"
  network = google_compute_network.myvpc.id 
}
```

## Step-05: Resource Block: c4-firewallrules.tf
- Create [FIREWALL RULES](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)
```t
# Firewall Rule: SSH
resource "google_compute_firewall" "fw_ssh" {
  name = "fwrule-allow-ssh22"
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
  name = "fwrule-allow-http80"
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

## Step-06: Resource block: c5-vminstance.tf 
- Create [Compute Instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
- Understand about [File Function](https://www.terraform.io/docs/language/functions/file.html)
- Understand about [Resources - Argument Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#argument-reference)
- Understand about [Resources - Attribute Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#attributes-reference)
```t
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = "myapp1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Install Webserver
  metadata_startup_script = file("${path.module}/webserver-install.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id 
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```

## Step-07: Review file app1-webserver-install.sh
```sh
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
sudo mkdir -p /var/www/html/app1
HOSTNAME=$(hostname)
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/app1/index.html
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/index.html
```

## Step-08: Execute Terraform Commands
```t
# Configure GCP Credentials
gcloud auth application-default login

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
Observation:
1) No changes - Just prints the execution plan

# Terraform Apply
terraform apply 
[or]
terraform apply -auto-approve
Observations:
1) Create resources on cloud
2) Created terraform.tfstate file when you run the terraform apply command
```

## Step-09: Access Application
- **Important Note:** verify if default VPC security group has a rule to allow port 80
```t
# Access index.html
http://<EXTERNAL-IP>/index.html
```

## Step-10: Terraform State - Basics
- Understand about Terraform State
- Terraform State file `terraform.tfstate`
- Understand about `Desired State` and `Current State`
```t
# Terraform State List
terraform state list

# Terraform State Show
terraform state show <RESOURCE-ADDRESS>
terraform state show google_compute_network.myvpc
```

## Step-11: Clean-Up
```t
# Terraform Destroy
terraform plan -destroy  # You can view destroy plan using this command
terraform destroy

# Clean-Up Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```


