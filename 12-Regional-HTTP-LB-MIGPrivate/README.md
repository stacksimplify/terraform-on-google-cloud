---
title: GCP Google Cloud Platform - Regional Application Load Balancer with MIG Private using Terraform
description: Learn Regional Application Load Balancer with MIG Private using Terraform on Google Cloud Platform
---

## Step-01: Introduction
1. Remove Public IPs for VMs (Comment instace template access_config attribute)
2. Create Health Check Firewall for GCP to perform health checks
3. Reference Health check firewall in Instance Template
4. Create CLOUD NAT, CLOUD ROUTER
  - [google_compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
  resource "google_compute_router_nat" "cloud_nat" {
  - [google_compute_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)

## Step-02: c6-01-instance-template.tf
- Comment **access_config** block 
```hcl
# Google Compute Engine: Regional Instance Template
resource "google_compute_region_instance_template" "myapp1" {
  name        = "${local.name}-myapp1-template"
  description = "This template is used to create MyApp1 server instances."
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
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
    subnetwork = google_compute_subnetwork.mysubnet.id 
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

## Step-03: c4-firewallrules.tf
```hcl
# Firewall rule: Allow Health checks
resource "google_compute_firewall" "fw_health_checks" {
  name    = "fwrule-allow-health-checks"
  network = google_compute_network.myvpc.id 
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["allow-health-checks"]
}
```
## Step-05: c6-01-instance-template.tf: Update firewall rule in Instance Template
```t
# Comment Old one
  #tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
# Add new one  
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
```

## Step-06: c8-Cloud-NAT-Cloud-Router.tf
- [google_compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
resource "google_compute_router_nat" "cloud_nat" {
- [google_compute_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)
```hcl
# Resource: Cloud Router
resource "google_compute_router" "cloud_router" {
  name    = "${local.name}-${var.gcp_region1}-cloud-router"
  network = google_compute_network.myvpc.id
  region  = var.gcp_region1
}

# Resource: Cloud NAT
resource "google_compute_router_nat" "cloud_nat" {
  name   = "${local.name}-${var.gcp_region1}-cloud-nat"
  router = google_compute_router.cloud_router.name
  region = google_compute_router.cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}
```
## Step-07: Execute Terraform Commands
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

# Step-08: Verify Resources
1. Static IP
2. Load Balancer
3. MIG
4. VM Instnaces (Should not have external ip assigned)
5. Curl Test
```t
# Curl test
curl <http://LOAD-BALANCER-IP>
curl 146.148.91.239
while true; do curl 146.148.91.239; sleep 1; done
```

## Step-12: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```


