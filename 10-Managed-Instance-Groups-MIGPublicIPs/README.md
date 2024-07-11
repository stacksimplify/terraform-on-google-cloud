---
title: GCP Google Cloud Platform - Managed Instance Groups using Terraform
description: Learn GCE Compute Engine Managed Instance Groups using Terraform on Google Cloud Platform
---

## Step-01: Introduction
1. **MIG Healthcheck:** [google_compute_region_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check)
2. **MIG Stateless:** [google_compute_region_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager)
3. **MIG Autoscaling:** [google_compute_region_autoscaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler)

## Step-02: c6-02-app1-mig-healthcheck.tf
- [google_compute_region_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check)
```hcl
# Resource: Regional Health Check
resource "google_compute_region_health_check" "myapp1" {
  name                = "${local.name}-myapp1"
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

## Step-03: c6-03-app1-mig.tf
- [google_compute_region_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager)
```hcl
# Resource: Managed Instance Group
resource "google_compute_region_instance_group_manager" "myapp1" {
  name                       = "${local.name}-myapp1-mig"
  base_instance_name         = "${local.name}-myapp1"
  region                     = var.gcp_region1
  distribution_policy_zones  = data.google_compute_zones.available.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.myapp1.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autosclaing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.myapp1.id
    initial_delay_sec = 300
  }
}
```

## Step-04: c6-04-app1-mig-autoscaling.tf
- [google_compute_region_autoscaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler)
```hcl
# Resource: MIG Autoscaling
resource "google_compute_region_autoscaler" "myapp1" {
  name   = "${local.name}-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.myapp1.id
  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 2
    cooldown_period = 60 
    cpu_utilization {
      target = 0.9
    }
  }
}
```

## Step-05: c6-05-app1-mig-outputs.tf
```hcl
# Terraform Output Values
output "myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.myapp1.id 
}

output "myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.myapp1.instance_group
}

output "myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.myapp1.self_link
}

output "myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.myapp1.status
}
```

## Step-06: Execute Terraform Commands
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

# Step-07: Verify VM Instances
- Go to Google Cloud -> Compute Engine, verify
- Managed Instance Groups
- VM Instances
  - **Key Observation:** VM Instances will have external or public IP assigned


## Step-08: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```


