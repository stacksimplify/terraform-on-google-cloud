---
title: GCP Google Cloud Platform - Terraform Meta-Argument Count
description: Learn Terraform Meta-Argument Count on Google Cloud Platform
---
## Step-01: Introduction
1. Terraform Meta-argument **count**
2. For Loop with List
3. For Loop with Map
4. For Loop with Map Advanced
5. Legacy Splat Operator (latest) - Returns List
6. Latest Generalized Splat Operator - Returns the List

## Step-02: c5-vminstance.tf - Meta-Argument count
```hcl
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  # Meta-Argument: count
  count = 2
  name         = "myapp1-vm-${count.index}"
  machine_type = var.machine_type
  zone         = var.gcp_region1
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


## Step-03: c6-output-values.tf - Learn the following concepts
1. For Loop with List
2. For Loop with Map
3. For Loop with Map Advanced
4. Legacy Splat Operator (latest) - Returns List
5. Latest Generalized Splat Operator - Returns the List
```hcl
# Terraform Output Values
/* Concepts Covered
1. For Loop with List
2. For Loop with Map
3. For Loop with Map Advanced
4. Legacy Splat Operator (latest) - Returns List
5. Latest Generalized Splat Operator - Returns the List
*/

# Get each list item separately
output "vm_name_0" {
  description = "VM Name"
  value = google_compute_instance.myapp1[0].name
}

# Get each list item separately
output "vm_name_1" {
  description = "VM Name"
  value = google_compute_instance.myapp1[1].name
}

# Output - For Loop with List
output "for_output_list" {
  description = "For Loop with List"
  value = [for instance in google_compute_instance.myapp1: instance.name]
}


# Output - For Loop with Map
output "for_output_map1" {
  description = "For Loop with Map"
  value = {for instance in google_compute_instance.myapp1: instance.name => instance.instance_id}
}

# Output - For Loop with Map Advanced
output "for_output_map2" {
  description = "For Loop with Map - Advanced"
  value = {for c, instance in google_compute_instance.myapp1: c => instance.name}
}

# Output - For Loop with Map Advanced
output "for_output_map3" {
  description = "For Loop with Map - Advanced (Instance Name and Instance ID)"
  value = {for c, instance in google_compute_instance.myapp1: instance.name => instance.instance_id}
}

# VM External IPs
output "vm_external_ips" {
  description = "For Loop with Map - Advanced"
  value = {for c, instance in google_compute_instance.myapp1: c => instance.network_interface.0.access_config.0.nat_ip}
}


# Output Legacy Splat Operator (Legacy) - Returns the List
output "legacy_splat_instance" {
  description = "Legacy Splat Operator"
  value = google_compute_instance.myapp1.*.name
}

# Output Latest Generalized Splat Operator - Returns the List
output "latest_splat_instance" {
  description = "Generalized latest Splat Operator"
  value = google_compute_instance.myapp1[*].name 
}

/* 
------- FOR SINGLE VM INSTANCE -------
# Terraform Output Values
## ATTRIBUTES
output "vm_instanceid" {
  description = "VM Instance ID"
  value = google_compute_instance.myapp1.instance_id
}

output "vm_selflink" {
  description = "VM Instance Self link"
  value = google_compute_instance.myapp1.self_link
}

output "vm_id" {
  description = "VM ID"
  value = google_compute_instance.myapp1.id
}

## ARGUMENTS
output "vm_name" {
  description = "VM Name"
  value = google_compute_instance.myapp1.name
}

output "vm_machine_type" {
  description = "VM Machine Type"
  value = google_compute_instance.myapp1.machine_type
}
*/
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

# Step-05: Verify VM Instances
- Go to Google Cloud -> Compute Engine -> VM Instances
- **Observation:** Both VM Instances will be created in same zone

## Step-06: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
