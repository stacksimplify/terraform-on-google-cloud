---
title: GCP Google Cloud Platform - Terraform Meta-argument for_each
description: Learn  Terraform Meta-argument for_each on Google Cloud Platform
---

## Step-01: Introduction
- Learn [Terraform Meta-argument for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- **Demo-01:** We are going to use `set values` for `for_each`
- **Demo-02:** We are going to use `Map values` for `for_each`

## Step-02: Demo01: D1-terraform-manifests
- We are going to use `set values` for `for_each`
### Step-02-01: c6-01-vminstance.tf
```hcl
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  # Meta-Argument: for_each
  for_each = toset(data.google_compute_zones.available.names)
  name         = "myapp1-vm-${each.key}"
  machine_type = var.machine_type
  zone        = each.key # You can also use each.value because for list items each.key == each.value
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```

### Step-02-02: c6-02-vminstance-outputs.tf
```hcl
# Terraform Output Values
# Output - For with list
output "for_output_list1" {
  description = "For Loop with List"
  value = [for instance in google_compute_instance.myapp1: instance.name]
}

# Output - For Loop with Map 
output "for_output_map1" {
  description = "For Loop with Map1"
  value = {for instance in google_compute_instance.myapp1: instance.name => instance.instance_id}
}

# Output - VM External IPs
output "vm_external_ips" {
  description = "VM Instance Names -> VM External IPs"
  value = {for instance in google_compute_instance.myapp1: instance.name => instance.network_interface.0.access_config.0.nat_ip}
}
```

### Step-02-03: Execute Terraform Commands
```t
# Change Directory
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

## Step-02-04: Verify VM Instances
- Go to Google Cloud -> Compute Engine -> VM Instances
- **Observation:** 
  - VM Instances will be created in each and every zone. 
  - If we have 4 zones in that region, 4 VM instances will be created

## Step-02-05: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```


## Step-03: Demo02: D2-terraform-manifests
- We are going to use `map values` for `for_each`
### Step-03-01: c6-01-vminstance.tf
```hcl
# Define a map with zone as key and machine_type as value
variable "zone_machine_map" {
  type = map(string)
  default = {
    "us-central1-a" = "e2-micro"
    "us-central1-b" = "e2-small"
    "us-central1-c" = "e2-medium"
  }
}
# Resource Block: Create a Compute Engine instance
resource "google_compute_instance" "myapp1" {
  # Meta-Argument: for_each
  for_each = var.zone_machine_map
  name         = "myapp1-vm-${each.key}"
  machine_type = each.value
  zone         = each.key
  tags = [
    tolist(google_compute_firewall.fw_ssh.target_tags)[0],
    tolist(google_compute_firewall.fw_http.target_tags)[0]
  ]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

```

### Step-03-02: Execute Terraform Commands
```t
# Change Directory
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

## Step-03-03: Verify VM Instances
- Go to Google Cloud -> Compute Engine -> VM Instances
- **Observation:** 
  - VM Instances will be created with different machine types


## Step-03-04: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
