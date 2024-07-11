---
title: GCP Google Cloud Platform - Selfsigned SSL with Certmanager
description: Learn to Selfsigned SSL with CertManager using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- We will use [Certificate Manager (latest)](https://cloud.google.com/certificate-manager/docs/overview) for SSL Certificates
- We will create self-signed certificates
- Apply them to load balancer and test HTTPS URL
- Implement HTTP to HTTPS redirect

## Step-02: COPY from previous section 13-Regional-HTTP-LB-MIGUpdatePolicy
- Remove `c9-01-instance-template.tf`
- Remove `v2-app1-webserver-install.sh`
- **c6-03-app1-mig.tf:** Ensure only V1 version exists in version block
```hcl
  # Instance Template
  version {
    # V1 Version
    instance_template = google_compute_region_instance_template.myapp1.id
  }
```

## Step-03: Create Self-signed SSL certificates
```t
# Change Directory
cd terraform-manifests/self-signed-ssl

# Create your app1 key:
openssl genrsa -out app1.key 2048

# Create your app1 certificate signing request:
openssl req -new -key app1.key -out app1.csr -subj "/CN=app1.stacksimplify.com"

# Create your app1 certificate:
openssl x509 -req -days 7300 -in app1.csr -signkey app1.key -out app1.crt
```

## Step-04: c9-certificate-manager.tf
```hcl
# Resource: Certificate manager certificate
resource "google_certificate_manager_certificate" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-ssl-certificate"
  description = "${local.name} Certificate Manager SSL Certificate"
  scope       = "DEFAULT"
  self_managed {
    pem_certificate = file("${path.module}/self-signed-ssl/app1.crt")
    pem_private_key = file("${path.module}/self-signed-ssl/app1.key")
  }
  labels = {
    env = local.environment
  }
}
```

## Step-05: c7-01-loadbalancer.tf: Comment HTTP Proxy
```hcl
# Resource: Regional HTTP Proxy
resource "google_compute_region_target_http_proxy" "mylb" {
  name   = "${local.name}-mylb-http-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
}
```

## Step-06: c7-01-loadbalancer.tf: Create HTTPS Proxy
```hcl
# Resource: Regional HTTPS Proxy
resource "google_compute_region_target_https_proxy" "mylb" {
  name   = "${local.name}-mylb-https-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
  certificate_manager_certificates = [ google_certificate_manager_certificate.myapp1.id ]
}
```

## Step-07: c7-01-loadbalancer.tf: Update Regional Forwarding rule
- Update `port_range  = "80"`
- Update `target      = google_compute_region_target_https_proxy.mylb.self_link`
```hcl
# Resource: Regional Forwarding Rule
resource "google_compute_forwarding_rule" "mylb" {
  name        = "${local.name}-mylb-forwarding-rule"
  target      = google_compute_region_target_https_proxy.mylb.self_link
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  network = google_compute_network.myvpc.id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}
```

## Step-08: c7-03-loadbalancer-outputs.tf: Update 
```hcl
output "mylb_target_https_proxy_self_link" {
  description = "The self link of the target HTTPS proxy."
  value       = google_compute_region_target_https_proxy.mylb.self_link
}
```


## Step-05: Execute Terraform Commands
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

# Step-06: Verify Resources
1. Verify Load Balancer
2. Verify Certificate Manager SSL Certificate
```t
# Access HTTPS URL
https://<LOAD-BALANCER-IP>
```

## Step-07: c7-02-loadbalancer-http-to-https.tf
```hcl
# Resource: Regional URL Map for HTTP to HTTPS redirection
resource "google_compute_region_url_map" "http" {
  name = "${local.name}-myapp1-http-to-https-url-map"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# Resource: Regional Target HTTP Proxy for redirection
resource "google_compute_region_target_http_proxy" "http" {
  name   = "${local.name}-myapp1-http-to-https-proxy"
  url_map = google_compute_region_url_map.http.self_link
}

# Resource: Regional Forwarding Rule for HTTP to HTTPS redirection
resource "google_compute_forwarding_rule" "http" {
  name        = "${local.name}-myapp1-http-to-https-forwarding-rule"
  target      = google_compute_region_target_http_proxy.http.self_link
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  network = google_compute_network.myvpc.id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}
```

# Step-08: Verify Resources
1. Verify Load Balancer
```t
# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply

# Access HTTP URL
http://<LOAD-BALANCER-IP>
Observation:
1. HTTP URL will redirect to HTTPS URL
```

## Step-09: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
