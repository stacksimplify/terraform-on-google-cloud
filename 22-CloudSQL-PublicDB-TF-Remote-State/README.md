---
title: GCP Google Cloud Platform - CloudSQL Public Database
description: Learn to implement CloudSQL Public Database using Terraform on Google Cloud Platform
---
## Step-00: Introduction
- Cloud SQL Database with Public Endpoint

## Step-01: Create Cloud Storage Bucket to Store Terraform State files
- **Name your bucket:** gcplearn9-tfstate
- **Choose where to store your data:** 
  - **Region:** us-central1
- **Choose a storage class for your data:**  
  - **Set a default class:** Standard
- **Choose how to control access to objects:**  
  - **Prevent public access:** Enforce public access prevention on this bucket
  - **Access control:** uniform
- **Choose how to protect object data:** 
  - **Soft Delete:** leave to defaults
  - **Object versioning:** 90
  - **Expire noncurrent versions after:** 365
- Click on **CREATE**  
  
## Step-02: c1-versions.tf
- Add the `backend block` which is a Google Cloud Storage bucket
```hcl
# Terraform Settings Block
terraform {
  required_version = ">= 1.8"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.35.0"
    }
  }
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "cloudsql/publicdb"
  }
}
```

## Step-03: c2-01-variables.tf
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

## Step-04: c2-02-local-values.tf
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

## Step-05: c3-01-cloudsql.tf
```hcl
# Random DB Name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Resource: Cloud SQL Database Instance
resource "google_sql_database_instance" "mydbinstance" {
  name             = "${local.name}-mysql-${random_id.db_name_suffix.hex}"
  database_version = var.cloudsql_database_version
  deletion_protection = false 
  settings {
    tier = "db-f1-micro"
    edition = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_autoresize = true
    disk_autoresize_limit = 20
    disk_size = 10
    disk_type = "PD_SSD"
    backup_configuration {
      enabled = true
      binary_log_enabled = true      
    }
    ip_configuration {
      authorized_networks {
        name = "allow-from-internet"
        value = "0.0.0.0/0"
      }
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

## Step-06: c3-02-cloudsql-outputs.tf
```hcl
output "cloudsql_db_public_ip" {
  value = google_sql_database_instance.mydbinstance.public_ip_address
}
```
## Step-07: terraform.tfvars
```hcl
gcp_project     = "gcplearn9"
gcp_region1     = "us-central1"
environment     = "dev"
business_divsion = "hr"
cloudsql_database_version = "MYSQL_8_0"
```

## Step-08: Execute Terraform Commands
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

## Step-13: Verify Cloud SQL Database
- Goto Cloud SQL -> hr-dev-mysql -> Cloud SQL Studio
- **Database:** webappdb
- **User:** umsadmin
- **Password:** dbpassword11
- Review the Cloud SQL Studio

## Step-14: Connect to MySQL DB from Cloud Shell
```sql
# MySQL Commands
mysql -h <DB-PUBLIC-IP> -u umsadmin -pdbpassword11
mysql -h 35.224.97.113 -u umsadmin -pdbpassword11
mysql> show schemas;
```
