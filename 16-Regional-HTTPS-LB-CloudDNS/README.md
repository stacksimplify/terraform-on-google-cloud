---
title: GCP Google Cloud Platform - Selfsigned SSL with Certmanager
description: Learn to Selfsigned SSL with CertManager using Terraform on Google Cloud Platform
---
## Step-00: Pre-requisite
1. Registered Domain in Cloud Domians or any other Domain Provider
2. Create a Cloud DNS Zone for that respective Cloud Domain or Domain from other Domain provider


## Step-01: Introduction
- We will use [Certificate Manager (latest)](https://cloud.google.com/certificate-manager/docs/overview) for SSL Certificates
### Demo-01: Cloud DNS + Cloud Domains
- **Pre-requisite-1:** Cloud Domain is registered and ready to use
- **Pre-requisite-2:** Cloud DNS Zone is created and ready to use
- Create production grade SSL certificates using Certificate Manager and DNS Authorization
- Associate SSL Certificate to Load Balancer 
- Create Cloud DNS Record set (DNS registed the Load balancer IP to a domain name)
- Verify the application using DNS Name
- **Terraform Manifests Folder:** D1-terraform-manifests

### Demo-02: Cloud DNS + Domain from other domain provider (AWS Route53)
- **Pre-requiite-1:** Should have a registered domain in any other domain provider (Example: AWS Route53)
- Create Cloud DNS Zone 
- Update Domain Registrar (External) with Google Cloud DNS Zone Nameserver details
- Update DNS Name and Cloud DNS Zone in locals block
- Rest all is same as demo-01
  - Create production grade SSL certificates using Certificate Manager and DNS Authorization
  - Associate SSL Certificate to Load Balancer 
  - Create Cloud DNS Record set (DNS registed the Load balancer IP to a domain name)
  - Verify the application using DNS Name
- **Terraform Manifests Folder:** D2-terraform-manifests

## Step-02: COPY from previous section 14-Regional-HTTPS-LB-SelfSigned
1. Delete self-signed-ssl folder in terraform-manifests
2. Delete c9-certificate-manager.tf

## Step-03: Demo-01: Cloud DNS + Cloud Domains
- **Terraform Manifests Folder:** D1-terraform-manifests
### Step-03-01: c9-cloud-dns.tf
```hcl
locals {
  mydomain = "myapp1.devopsincloud.com"
  dns_managed_zone = "devopsincloud-com"
}

# Resource: Cloud DNS Record Set for A Record
resource "google_dns_record_set" "a_record" {
  #project      = "kdaida123"
  managed_zone = "${local.dns_managed_zone}"
  name         = "${local.mydomain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.mylb.address]
}
```

### Step-03-02: c10-certificate-manager.tf
```hcl
# Resource: Certificate Manager DNS Authorization
resource "google_certificate_manager_dns_authorization" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-myapp1-dns-authorization"
  description = "myapp1 dns authorization"
  domain      = "${local.mydomain}"
}

# Resource: Certificate manager certificate
resource "google_certificate_manager_certificate" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-myapp1-ssl-certificate"
  description = "${local.name} Certificate Manager SSL Certificate"
  scope       = "DEFAULT"
  labels = {
    env = "dev"
  }
  managed {
    domains = [
      google_certificate_manager_dns_authorization.myapp1.domain
      ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.myapp1.id
      ]
  }
}


# Resource: DNS record to be created in DNS zone for DNS Authorization
resource "google_dns_record_set" "myapp1_cname" {
  project      = "kdaida123"
  managed_zone = "${local.dns_managed_zone}"
  name         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].data]
}
```

### Step-03-03: c7-01-loadbalancer.tf
- Verify HTTPS proxy mapped with SSL certificate from Certificate manager
```hcl
# Resource: Regional HTTPS Proxy
resource "google_compute_region_target_https_proxy" "mylb" {
  name   = "${local.name}-mylb-https-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
  certificate_manager_certificates = [ google_certificate_manager_certificate.myapp1.id ]
}
```

### Step-03-04: Execute Terraform Commands
```t
# Change Directroy
cd D1-terraform-manifests

# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply
```

### Step-03-05: Verify Resources
1. Verify Load Balancer
2. Verify Certificate Manager SSL Certificate
```t
# Access HTTP URL
http://<DNS URL>
Observation:
1. DNS URL should redirct to HTTPS URL
```

### Step-03-06:  Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```

## Step-04: Demo-02: Cloud DNS + AWS Route53 as Domain Registrar
- **Terraform Manifests Folder:** D2-terraform-manifests
### Step-04-01: Create Cloud DNS Zone
- Goto Cloud DNS Zones -> **CREATE ZONE**
- **Zone name:** devopsincloud-com
- **DNS Name:** devopsincloud.com
- **Description:** devopsincloud-com
- REST ALL LEAVE TO DEFAULTS
- Click on **CREATE**

### Step-04-02: c9-cloud-dns.tf
```hcl
locals {
  mydomain = "myapp1.devopsincloud.com"
  dns_managed_zone = "devopsincloud-com"
}
```

### Step-04-03: c9-cloud-dns.tf
- Comment `#project      = "kdaida123"` argument
- We have created DNS zone in same project where we are working, so `project` argument not needed.
```hcl
# Resource: Cloud DNS Record Set for A Record
resource "google_dns_record_set" "a_record" {
  #project      = "kdaida123"
  managed_zone = "${local.dns_managed_zone}"
  name         = "${local.mydomain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.mylb.address]
}
```

### Step-04-04: c10-certificate-manager.tf
- Comment `#project      = "kdaida123"` argument
- We have created DNS zone in same project where we are working, so `project` argument not needed.
```hcl
# Resource: DNS record to be created in DNS zone for DNS Authorization
resource "google_dns_record_set" "myapp1_cname" {
  #project      = "kdaida123"
  managed_zone = "${local.dns_managed_zone}"
  name         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].data]
}
```

### Step-04-05: Execute Terraform Commands
```t
# Change Directroy
cd D2-terraform-manifests

# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply
```

### Step-04-06: Verify Resources
1. Verify Load Balancer
2. Verify Certificate Manager SSL Certificate
```t
# Access HTTP URL
http://<DNS URL>
Observation:
1. DNS URL should redirct to HTTPS URL
```

### Step-04-07:  Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```

