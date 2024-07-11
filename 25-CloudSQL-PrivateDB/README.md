---
title: GCP Google Cloud Platform - CloudSQL Private Database
description: Learn to implement CloudSQL Private Database using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Cloud SQL Database with Private Endpoint

## Step-02: COPY from 22-CloudSQL-PublicDB
- **COPY FROM:** 22-CloudSQL-PublicDB/p1-cloudsql-publicdb
- **COPY TO:** 25-CloudSQL-PrivateDB/p1-cloudsql-privatedb

## Step-03: c1-versions.tf
- Add the `backend block` which is a Google Cloud Storage bucket
```hcl
# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.35.0"
    }
  }
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "cloudsql/privatedb"
  }  
}

# Terraform Provider Block
provider "google" {
  project = var.gcp_project
  region = var.gcp_region1
}
```

## Step-04: c2-01-variables.tf
```hcl
# Input Variables
# GCP Project
variable "gcp_project" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = "kdaida123"
}

# GCP Region
variable "gcp_region1" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = "us-east1"
}

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


# Cloud SQL Database version
variable "cloudsql_database_version" {
  description = "Cloud SQL MySQL DB Database version"
  type = string
  default = "MYSQL_8_0"
}
```

## Step-05: c2-02-local-values.tf
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

## Step-06: c3-01-vpc.tf
```hcl
# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name = "${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/24"
  network = google_compute_network.myvpc.id 
}

# Resource: Regional Proxy-Only Subnet (Required for Regional Application Load Balancer)
resource "google_compute_subnetwork" "regional_proxy_subnet" {
  name             = "${var.gcp_region1}-regional-proxy-subnet"
  region           = var.gcp_region1
  ip_cidr_range    = "10.0.0.0/24"
  purpose          = "REGIONAL_MANAGED_PROXY"
  network          = google_compute_network.myvpc.id
  role             = "ACTIVE"
}
```

## Step-07: c3-02-private-service-connection.tf
```hcl
## CONFIGS RELATED TO CLOUD SQL PRIVATE CONNECTION
# Resource: Reserve Private IP range for VPC Peering
resource "google_compute_global_address" "private_ip" {
  name          = "${local.name}-vpc-peer-privateip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.myvpc.id  
}

# Resource: Private Service Connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.myvpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}
```

## Step-08: c3-03-vpc-outputs.tf
```hcl
output "vpc_id" {
  description = "VPC ID"
  value = google_compute_network.myvpc.id 
}

output "mysubnet_id" {
  description = "Subnet ID"
  value = google_compute_subnetwork.mysubnet.id 
}

output "regional_proxy_subnet_id" {
  description = "Regional Proxy Subnet ID"
  value = google_compute_subnetwork.regional_proxy_subnet.id 
}
```

## Step-09: c4-01-cloudsql.tf
- Update `ip_configuration` with `private_network = google_compute_network.myvpc.self_link` argument     
```hcl
# Random DB Name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}
# Resource: Cloud SQL Database Instance
resource "google_sql_database_instance" "mydbinstance" {
  # Create DB only after Private VPC connection is created
  depends_on = [ google_service_networking_connection.private_vpc_connection ]
  name = "${local.name}-mysql-${random_id.db_name_suffix.hex}"
  database_version = var.cloudsql_database_version
  project = var.gcp_project
  deletion_protection = false
  settings {
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"      # Other option is "ENTERPRISE_PLUS"
    availability_type = "ZONAL" # FOR HA use "REGIONAL"
    disk_autoresize = true
    disk_autoresize_limit = 20
    disk_size = 10
    disk_type = "PD_SSD"
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.myvpc.self_link      
    }
  }
}

# Resource: Cloud SQL Database Schema
resource "google_sql_database" "mydbschema" {
  name     = "webappdb"
  instance = google_sql_database_instance.mydbinstance.name
}

# Resource: Cloud SQL Database User
resource "google_sql_user" "users" {
  name     = "umsadmin"
  instance = google_sql_database_instance.mydbinstance.name
  host     = "%"
  password = "dbpassword11"
}
```

## Step-10: c4-02-cloudsql-outputs.tf
```hcl
output "cloudsql_db_private_ip" {
  value = google_sql_database_instance.mydbinstance.private_ip_address
}
```

## Step-11: mysql-client-install.sh
```sh
#! /bin/bash
# Update package list
sudo apt update

# Install telnet (For Troubelshooting)
sudo apt install -y telnet

# Install MySQL Client (For Troubelshooting)
sudo apt install -y default-mysql-client
``` 

## Step-12: c5-vminstance.tf
```hcl
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

# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = "mysq-client"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0]]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/mysql-client-install.sh")
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

output "vm_public_ip" {
  value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
}
```

## Step-13: terraform.tfvars
```hcl
gcp_project     = "gcplearn9"
gcp_region1     = "us-central1"
environment     = "dev"
business_divsion = "hr"
cloudsql_database_version = "MYSQL_8_0"
```

## Step-14: Execute Terraform Commands
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

## Step-15: Verify Cloud SQL Database
- Goto Cloud SQL -> hr-dev-mysql -> Cloud SQL Studio
- **Database:** webappdb
- **User:** umsadmin
- **Password:** dbpassword11
- Review the Cloud SQL Studio

## Step-16: Connect to MySQL DB from VM Instance
```sql
## SSH TO VM
SSH to VM using Cloud Shell

# MySQL Commands
mysql -h <DB-PRIVATE-IP> -u umsadmin -pdbpassword11
mysql -h 10.40.0.6 -u umsadmin -pdbpassword11
mysql> show schemas;
```
