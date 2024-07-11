---
title: GCP Google Cloud Platform - Global Application Load Balancer
description: Learn to implement Global Application Load Balancer using Terraform
---

## Step-01: Introduction
- Create Global Application Load Balancer which will load balance MYAPP1 application deployed in two regions (us-central1, asia-south1)

## Step-02: Terraform Manifests and Variables
### Step-02-00: Terraform Manifests are COPY OF 12-Regional-HTTP-LB-MIGPrivate
- COPY OF 12-Regional-HTTP-LB-MIGPrivate/terraform-manifests
### Step-02-01: c2-01-variables.tf
```hcl
# GCP Region
variable "gcp_region2" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = "asia-south1"
}
```
### Step-02-02: terraform.tfvars
```hcl
gcp_project     = "gcplearn9"
gcp_region1     = "us-central1"
gcp_region2     = "asia-south1"
machine_type    = "e2-micro"
environment     = "dev"
business_divsion = "hr"
```

## Step-03: c3-vpc.tf
- Create subnets for Region-1 and Region-2
```hcl
# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet (Region1)
resource "google_compute_subnetwork" "region1" {
  name = "${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/20"
  network = google_compute_network.myvpc.id 
}

# Resource: Subnet (Region2)
resource "google_compute_subnetwork" "region2" {
  name = "${var.gcp_region2}-subnet"
  region = var.gcp_region2
  ip_cidr_range = "10.132.0.0/20"
  network = google_compute_network.myvpc.id 
  private_ip_google_access = true 
}
```

## Step-04: c5-datasources.tf
- Define `google_compute_zones` datasource for both Region1 and Region2
```hcl
# Terraform Datasources
data "google_compute_zones" "region1" {  
  region = var.gcp_region1
  status = "UP"
}
data "google_compute_zones" "region2" {  
  region = var.gcp_region2
  status = "UP"
}


# Output value
output "region1_compute_zones" {
  description = "List the compute zones"
  value = data.google_compute_zones.region1.names
}
output "region2_compute_zones" {
  description = "List the compute zones"
  value = data.google_compute_zones.region2.names
}
```

## Step-05: c6-01-app1-instance-template.tf
- Create two instance templates 1 for each region, other option is to create one global instance template but best recommended is to use regional instance templates
- **Instance Template:** region1_myapp1
  - region = var.gcp_region1
  - subnetwork = google_compute_subnetwork.region1.id 
- **Instance Template:** region2_myapp1
  - region = var.gcp_region2
  - subnetwork = google_compute_subnetwork.region2.id 
```hcl
# Google Compute Engine: Regional Instance Template: Region1
resource "google_compute_region_instance_template" "region1_myapp1" {
  region = var.gcp_region1
  name        = "${local.name}-myapp1-template"
  description = "This template is used to create MyApp1 server instances."
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
  instance_description = "MyApp1 VM Instances"
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
    subnetwork = google_compute_subnetwork.region1.id 
    /*access_config {
      # Include this section to give the VM an external IP address
    } */ 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}

# Google Compute Engine: Regional Instance Template: Region2
resource "google_compute_region_instance_template" "region2_myapp1" {
  region = var.gcp_region2
  name        = "${local.name}-myapp1-template"
  description = "This template is used to create MyApp1 server instances."
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
  instance_description = "MyApp1 VM Instances"
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
    subnetwork = google_compute_subnetwork.region2.id 
    /*access_config {
      # Include this section to give the VM an external IP address
    } */ 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}
```

## Step-06: c6-02-app1-mig-healthcheck.tf
- Create two health checks 1 for each region
- **Healthcheck:** region1_myapp1
  - region = var.gcp_region1
  - name = "${local.name}-${var.gcp_region1}-myapp1-health-check"
- **Healthcheck:** region2_myapp1
  - region = var.gcp_region2
  - name = "${local.name}-${var.gcp_region2}-myapp1-health-check"
```hcl
# Resource: Regional Health Check: Region1
resource "google_compute_region_health_check" "region1_myapp1" {
  region              = var.gcp_region1
  name                = "${local.name}-${var.gcp_region1}-myapp1-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}

# Resource: Regional Health Check: Region2
resource "google_compute_region_health_check" "region2_myapp1" {
  region              = var.gcp_region2
  name                = "${local.name}-${var.gcp_region2}-myapp1-health-check"
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

## Step-07: c6-03-app1-mig.tf
- Create two managed instance groups 1 in each region
- **MIG:** region1_myapp1
  - region = var.gcp_region1
  - depends_on = [ google_compute_router_nat.region1_cloud_nat ]
  - name = "${local.name}-${var.gcp_region1}-myapp1-mig"
  - base_instance_name = "${local.name}-${var.gcp_region1}-myapp1"
  - distribution_policy_zones  = data.google_compute_zones.region1.names 
  - instance_template = google_compute_region_instance_template.region1_myapp1.id 
  - health_check      = google_compute_region_health_check.region1_myapp1.id
- **MIG:** region2_myapp1
  - region = var.gcp_region2
  - depends_on = [ google_compute_router_nat.region2_cloud_nat ]
  - name = "${local.name}-${var.gcp_region2}-myapp1-mig"
  - base_instance_name = "${local.name}-${var.gcp_region2}-myapp1"
  - distribution_policy_zones  = data.google_compute_zones.region2.names 
  - instance_template = google_compute_region_instance_template.region2_myapp1.id 
  - health_check      = google_compute_region_health_check.region2_myapp1.id
```hcl
## Resource: Managed Instance Group: Region1
resource "google_compute_region_instance_group_manager" "region1_myapp1" {
  depends_on = [ google_compute_router_nat.region1_cloud_nat ]
  region                     = var.gcp_region1
  name                       = "${local.name}-${var.gcp_region1}-myapp1-mig"
  base_instance_name         = "${local.name}-${var.gcp_region1}-myapp1"
  distribution_policy_zones  = data.google_compute_zones.region1.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.region1_myapp1.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autohealing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.region1_myapp1.id
    initial_delay_sec = 300
  }
}

# Resource: Managed Instance Group: Region2
resource "google_compute_region_instance_group_manager" "region2_myapp1" {
  depends_on = [ google_compute_router_nat.region2_cloud_nat ]
  region                     = var.gcp_region2
  name                       = "${local.name}-${var.gcp_region2}-myapp1-mig"
  base_instance_name         = "${local.name}-${var.gcp_region2}-myapp1"
  distribution_policy_zones  = data.google_compute_zones.region2.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.region2_myapp1.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autohealing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.region2_myapp1.id
    initial_delay_sec = 300
  }
}
```


## Step-08: c6-04-mig-autoscaling.tf
- Create two Autoscaling resources 1 for each regional MIG
- **MIG Autoscaling:** region1_myapp1
  - region = var.gcp_region1
  - name   = "${local.name}-${var.gcp_region1}-mig-myapp1-autoscaler"
  - target = google_compute_region_instance_group_manager.region1_myapp1.id  
- **MIG Autoscaling::** region2_myapp1
  - region = var.gcp_region2
  - name   = "${local.name}-${var.gcp_region2}-mig-myapp1-autoscaler"
  - target = google_compute_region_instance_group_manager.region2_myapp1.id  
```hcl
# Resource: MIG Autoscaling: Region1
resource "google_compute_region_autoscaler" "region1_myapp1" {
  region = var.gcp_region1
  name   = "${local.name}-${var.gcp_region1}-mig-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.region1_myapp1.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60  
    cpu_utilization {
      target = 0.9
    }
  }
}

# Resource: MIG Autoscaling: Region2
resource "google_compute_region_autoscaler" "region2_myapp1" {
  region = var.gcp_region2
  name   = "${local.name}-${var.gcp_region2}-mig-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.region2_myapp1.id
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

## Step-09: c6-05-app1-mig-outputs.tf
- Create Region1 and Region 2 mig outputs
```hcl
# Terraform Output Values: 
# MIG Outputs Region1
output "region1_myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.region1_myapp1.id 
}

output "region1_myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.region1_myapp1.instance_group
}

output "region1_myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.region1_myapp1.self_link
}

output "region1_myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.region1_myapp1.status
}

# MIG Outputs Region2
output "region2_myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.region2_myapp1.id 
}

output "region2_myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.region2_myapp1.instance_group
}

output "region2_myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.region2_myapp1.self_link
}

output "region2_myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.region2_myapp1.status
}
```

## Step-10: c7-01-loadbalancer.tf
- Create following resources
  - Global Static IP
  - Global Health check  
  - Global Backend Service
  - Global URL Map
  - Global HTTP Proxy
  - Global Forwarding Rule
```hcl
# Resource: Reserve global Static IP Address
resource "google_compute_global_address" "mylb" {
  name   = "${local.name}-global-static-ip"
}

# Resource: Global Health Check
resource "google_compute_health_check" "mylb" {
  name                = "${local.name}-mylb-myapp1-global-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}

# Resource: Global Backend Service
resource "google_compute_backend_service" "mylb" {
  name                  = "${local.name}-myapp1-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group = google_compute_region_instance_group_manager.region1_myapp1.instance_group
    capacity_scaler = 0.5
    balancing_mode = "UTILIZATION"
  }
  backend {
    group = google_compute_region_instance_group_manager.region2_myapp1.instance_group
    capacity_scaler = 0.5
    balancing_mode = "UTILIZATION"
  }  
}

# Resource: Global URL Map
resource "google_compute_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_backend_service.mylb.self_link
}

# Resource: Global HTTP Proxy
resource "google_compute_target_http_proxy" "mylb" {
  name   = "${local.name}-mylb-http-proxy"
  url_map = google_compute_url_map.mylb.self_link
}

# Resource: Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "mylb" {
  name        = "${local.name}-mylb-forwarding-rule"
  target      = google_compute_target_http_proxy.mylb.self_link
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address = google_compute_global_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP Global LB (not classic)
}
```

## Step-11: c7-02-loadbalancer-outputs.tf
- Update all Load Balancer outputs with global resources
```hcl
output "mylb_static_ip_address" {
  description = "The static IP address of the load balancer."
  value       = google_compute_global_address.mylb.address
}

output "mylb_backend_service_self_link" {
  description = "The self link of the backend service."
  value       = google_compute_backend_service.mylb.self_link
}

output "mylb_url_map_self_link" {
  description = "The self link of the URL map."
  value       = google_compute_url_map.mylb.self_link
}

output "mylb_target_http_proxy_self_link" {
  description = "The self link of the target HTTP proxy."
  value       = google_compute_target_http_proxy.mylb.self_link
}

output "mylb_forwarding_rule_ip_address" {
  description = "The IP address of the forwarding rule."
  value       = google_compute_global_forwarding_rule.mylb.ip_address
}
```

## Step-12: c8-Cloud-NAT-Cloud-Router.tf
- Define Cloud NAT and Cloud Router for both regions
```hcl
# Resource: Cloud Router: Region1
resource "google_compute_router" "region1_cloud_router" {
  name    = "${local.name}-${var.gcp_region1}-cloud-router"
  network = google_compute_network.myvpc.id
  region  = var.gcp_region1
}

# Resource: Cloud NAT: Region1
resource "google_compute_router_nat" "region1_cloud_nat" {
  name   = "${local.name}-${var.gcp_region1}-cloud-nat"
  router = google_compute_router.region1_cloud_router.name
  region = google_compute_router.region1_cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}

# Resource: Cloud Router: Region2
resource "google_compute_router" "region2_cloud_router" {
  name    = "${local.name}-${var.gcp_region2}-cloud-router"
  network = google_compute_network.myvpc.id
  region  = var.gcp_region2
}

# Resource: Cloud NAT: Region2
resource "google_compute_router_nat" "region2_cloud_nat" {
  name   = "${local.name}-${var.gcp_region2}-cloud-nat"
  router = google_compute_router.region2_cloud_router.name
  region = google_compute_router.region2_cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}
```

## Step-13: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
```

## Step-14: Verify Resources
1. VPC
2. Subnets (both regions)
3. Firewall Rules
4. Instance Templates (both regions)
5. Managed Instance Groups (both regions)
6. Health Checks (both regions) + LB global health check
7. Global Application Load Balancer
8. Cloud NAT and Cloud Router (both regions)
9. Access Application
```t
# Access Application
http://<LB-IP>
curl http://<LB-IP>
Observation: request reaches nearest region VM instance (asia-south1 VM) because my local desktop located in same region. 

# Access from us-central1 VM
curl http://<LB-IP>
Observation: request reaches nearest region VM instance (us-central1 VM)

# Access from asia-south1 VM
curl http://<LB-IP>
Observation: request reaches nearest region VM instance (asia-south1 VM)

# Curl test in a loop
curl 34.160.171.144
while true; do curl 34.160.171.144; sleep 1; done
```