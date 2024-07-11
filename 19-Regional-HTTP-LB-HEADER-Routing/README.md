---
title: GCP Google Cloud Platform - Regional Application Load Balancer Header routing
description: Learn Regional Application Load Balancer Header routing using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Implement HTTP Header based routing
- Header Name and values
- appname: myapp1 -> Route to myapp1
- appname: myapp2 -> Route to myapp2
- appname: myapp5 -> Route to default which is myapp1

## Step-02: COPY OF 18-Regional-HTTP-LB-HOST-Routing
- COPY OF 18-Regional-HTTP-LB-HOST-Routing

## Step-03: c7-01-loadbalancer.tf
- URL Map with host based routing
```hcl

# Resource: Regional URL Map
resource "google_compute_region_url_map" "mylb" {
name            = "${local.name}-mylb-url-map"
  default_service = google_compute_region_backend_service.myapp1.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "my-path-routing-1"
  }

  path_matcher {
    name            = "my-path-routing-1"
    # App1: No appname, routes to default which is myapp1
    default_service = google_compute_region_backend_service.myapp1.id
    # App2 - Route based on Header
    route_rules {
      priority = 1
      service = google_compute_region_backend_service.myapp2.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        header_matches {
          header_name = "appname"
          exact_match = "myapp2"
        }
      }
    }
  }
}

```

## Step-04: Execute Terraform Commands
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

# Step-05: Verify Resources
1. Load Balancer
2. MIG
3. VM Instnaces 
4. Test using 
```t
# Curl Test
curl http://<LOAD-BALANCER-IP>
Observation:
1. Should get default backend which is myapp1

# Test Header Routing using 
URL: https://reqbin.com/
LB IP Address: http://<LOAD-BALANCER-IP>
appname: myapp1 -> Route to myapp1
appname: myapp2 -> Route to myapp2
appname: myapp5 -> Route to default which is myapp1
```

## Step-06: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
