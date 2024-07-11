---
title: GCP Google Cloud Platform - Regional Application Load Balancer using Terraform
description: Learn Regional Application Load Balancer using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)
- [google_compute_region_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check)
- [google_compute_region_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service)
- [google_compute_region_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map)
- [google_compute_region_target_http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy)
- [google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule)
- [google_compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)

## Step-02: c7-01-loadbalancer.tf: Regional Static IP
- [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)
```hcl
# Resource: Reserve Regional Static IP Address
resource "google_compute_address" "mylb" {
  name   = "${local.name}-mylb-regional-static-ip"
  region = var.gcp_region1
}
```

## Step-03: c7-01-loadbalancer.tf: Load Balancer Health Check
- [google_compute_region_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check)
```hcl
# Resource: Regional Health Check
resource "google_compute_region_health_check" "mylb" {
  name                = "${local.name}-mylb-myapp1-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}
```

## Step-04: c7-01-loadbalancer.tf: Regional Backend Service
- [google_compute_region_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service)
```hcl
# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "mylb" {
  name                  = "${local.name}-myapp1-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group = google_compute_region_instance_group_manager.myapp1.instance_group
    capacity_scaler = 1.0
    balancing_mode = "UTILIZATION"
  }
}
```

## Step-05: c7-01-loadbalancer.tf: Regional URL Map
- [google_compute_region_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map)
```hcl
# Resource: Regional URL Map
resource "google_compute_region_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_region_backend_service.mylb.self_link
}
```

## Step-06: c7-01-loadbalancer.tf: Regional HTTP Proxy
- [google_compute_region_target_http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy)
```hcl
# Resource: Regional HTTP Proxy
resource "google_compute_region_target_http_proxy" "mylb" {
  name   = "${local.name}-mylb-http-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
}
```

## Step-07: c3-vpc.tf: Regional Proxy Subnet
- [google_compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
```hcl
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

## Step-08: c7-01-loadbalancer.tf: Regional Forwarding rule
- [google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule)
```hcl
# Resource: Regional Forwarding Rule
resource "google_compute_forwarding_rule" "mylb" {
  name        = "${local.name}-mylb-forwarding-rule"
  target      = google_compute_region_target_http_proxy.mylb.self_link
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  network = google_compute_network.myvpc.id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}
```

## Step-09: c7-02-loadbalancer-outputs.tf
```hcl
output "mylb_static_ip_address" {
  description = "The static IP address of the load balancer."
  value       = google_compute_address.mylb.address
}

output "mylb_backend_service_self_link" {
  description = "The self link of the backend service."
  value       = google_compute_region_backend_service.mylb.self_link
}

output "mylb_url_map_self_link" {
  description = "The self link of the URL map."
  value       = google_compute_region_url_map.mylb.self_link
}

output "mylb_target_http_proxy_self_link" {
  description = "The self link of the target HTTP proxy."
  value       = google_compute_region_target_http_proxy.mylb.self_link
}

output "mylb_forwarding_rule_ip_address" {
  description = "The IP address of the forwarding rule."
  value       = google_compute_forwarding_rule.mylb.ip_address
}
```

## Step-10: Execute Terraform Commands
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

# Step-11: Verify Resources
1. Static IP
2. Load Balancer
3. MIG
4. VM Instnaces
5. Curl Test
```t
# Curl test
curl <http://LOAD-BALANCER-IP>
curl 34.41.176.65
while true; do curl 34.41.176.65; sleep 1; done
```

## Step-12: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```


