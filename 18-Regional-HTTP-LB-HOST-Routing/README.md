---
title: GCP Google Cloud Platform - Regional Application Load Balancer Host routing
description: Learn Regional Application Load Balancer Host routing using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Implement HTTP host based routing
- app1.stacksimplify.com -> Traffic routes to App1 MIG
- app2.stacksimplify.com -> Traffic routes to App2 MIG

## Step-02: COPY OF 17-Regional-HTTP-LB-PATH-Routing
- COPY OF 17-Regional-HTTP-LB-PATH-Routing

## Step-03: c7-01-loadbalancer.tf
- URL Map with host based routing
```hcl
# Resource: Regional URL Map
resource "google_compute_region_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_region_backend_service.myapp1.id

# App1 Host Rule
  host_rule {
    hosts        = ["app1.stacksimplify.com"]
    path_matcher = "app1-path-matcher"
  }
  path_matcher {
    name            = "app1-path-matcher"
    default_service = google_compute_region_backend_service.myapp1.id
  }

# App2 Host Rule
  host_rule {
    hosts        = ["app2.stacksimplify.com"]
    path_matcher = "app2-path-matcher"
  }
  path_matcher {
    name            = "app2-path-matcher"
    default_service = google_compute_region_backend_service.myapp2.id
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
4. Curl Test or access via browser
```t
# Update Host entries in your local desktop 
## Mac/Linux: /etc/hosts
## Windows: hosts file
34.46.228.212  app1.stacksimplify.com 
34.46.228.212  app2.stacksimplify.com 
34.46.228.212  default.stacksimplify.com 

# Curl test
curl http://app1.stacksimplify.com 
curl http://app2.stacksimplify.com 
curl http://default.stacksimplify.com 

# Access via browser
http://app1.stacksimplify.com 
http://app2.stacksimplify.com 
http://default.stacksimplify.com 
```

## Step-06: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```



