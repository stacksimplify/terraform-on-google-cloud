---
title: GCP Google Cloud Platform - Regional Application Load Balancer Path routing
description: Learn Regional Application Load Balancer Path routing using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Implement HTTP path based routing
- /app1/* -> Traffic routes to App1 MIG
- /app2/* -> Traffic routes to App2 MIG
- /* -> Traffic routes to App1 MIG (defaults to App1 MIG)

## Step-02: COPY OF 12-Regional-HTTP-LB-MIGPrivate
- COPY OF 12-Regional-HTTP-LB-MIGPrivate

## Step-03: Create App2 related Terraform configs
### Step-03-01: c6-06-app2-instance-template.tf
```hcl
# Google Compute Engine: Regional Instance Template
resource "google_compute_region_instance_template" "myapp2" {
  name        = "${local.name}-myapp2-template"
  description = "This template is used to create MyApp2 server instances."
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
  instance_description = "MyApp2 VM Instances"
  machine_type         = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  # Create a new boot disk from an image
  disk {
    #source_image      = "debian-cloud/debian-12"
    source_image      = data.google_compute_image.my_image.self_link
    auto_delete       = true
    boot              = true
  }
  # Network Info
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id 
    /*access_config {
      # Include this section to give the VM an external IP address
    } */ 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app2-webserver-install.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}
```
### Step-03-02: c6-07-app2-mig-healthcheck.tf
```hcl
# Resource: Regional Health Check
resource "google_compute_region_health_check" "myapp2" {
  name                = "${local.name}-myapp2"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/app2/index.html"
    port         = 80
  }
}
```
### Step-03-03: c6-08-app2-mig.tf
```hcl
# Resource: Managed Instance Group
resource "google_compute_region_instance_group_manager" "myapp2" {
  depends_on = [ google_compute_router_nat.cloud_nat ]
  name                       = "${local.name}-myapp2-mig"
  base_instance_name         = "${local.name}-myapp2"
  region                     = var.gcp_region1
  distribution_policy_zones  = data.google_compute_zones.available.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.myapp2.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autosclaing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.myapp2.id
    initial_delay_sec = 300
  }
}
```
### Step-03-04: c6-09-app2-mig-autoscaling.tf
```hcl
# Resource: MIG Autoscaling
resource "google_compute_region_autoscaler" "myapp2" {
  name   = "${local.name}-myapp2-autoscaler"
  target = google_compute_region_instance_group_manager.myapp2.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60 
    cpu_utilization {
      target = 0.9
    }
  }
}
```
### Step-03-05: c6-10-app2-mig-outputs.tf
```hcl
# Terraform Output Values
output "myapp2_mig_id" {
  value = google_compute_region_instance_group_manager.myapp2.id 
}

output "myapp2_mig_instance_group" {
  value = google_compute_region_instance_group_manager.myapp2.instance_group
}

output "myapp2_mig_self_link" {
  value = google_compute_region_instance_group_manager.myapp2.self_link
}

output "myapp2_mig_status" {
  value = google_compute_region_instance_group_manager.myapp2.status
}
```

## Step-04: c7-01-loadbalancer.tf
- MyApp1 Backend Service
- MyApp2 Backend Service
- URL Map with path based routing
```hcl
# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "myapp1" {
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

# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "myapp2" {
  name                  = "${local.name}-myapp2-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group = google_compute_region_instance_group_manager.myapp2.instance_group
    capacity_scaler = 1.0
    balancing_mode = "UTILIZATION"
  }
}


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
    default_service = google_compute_region_backend_service.myapp1.id

    path_rule {
      paths = ["/app1/*"]
      service = google_compute_region_backend_service.myapp1.id
    }

    path_rule {
      paths = ["/app2/*"]
      service = google_compute_region_backend_service.myapp2.id
    }
  }
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
1. Load Balancer
2. MIG
3. VM Instnaces (Should not have external ip assigned)
4. Curl Test or access via browser
```t
# Curl test
curl <http://LOAD-BALANCER-IP>
curl <http://LOAD-BALANCER-IP>/app1/index.html
curl <http://LOAD-BALANCER-IP>/app2/index.html
while true; do curl 146.148.91.239; sleep 1; done

# Access via browser
http://LOAD-BALANCER-IP
http://LOAD-BALANCER-IP/app1/index.html
http://LOAD-BALANCER-IP/app2/index.html
```

## Step-07: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```


