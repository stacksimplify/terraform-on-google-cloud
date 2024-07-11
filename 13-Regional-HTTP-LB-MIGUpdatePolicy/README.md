---
title: GCP Google Cloud Platform - Test MIG Update Policy using Terraform
description: Learn to test MIG Update Policy using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Create V2 version of application `v2-app1-webserver-install.sh`
- Create V2 version of instance template
- Add V2 version of instance template reference in c6-03-app1-mig.tf
- Add MIG Update policy in c6-03-app1-mig.tf
- Apply and Test V1 version
- Uncomment V2 version, Apply and Test V2 version 

## Step-02: v2-app1-webserver-install.sh
```sh
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
sudo mkdir -p /var/www/html/app1
HOSTNAME=$(hostname)
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(144, 238, 144);'> <h1>V2 - Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V2</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/app1/index.html
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(144, 238, 144);'> <h1>V2 - Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V2</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/index.html
```

## Step-03: c9-01-instance-template.tf
```hcl
# Google Compute Engine: Regional Instance Template V2 for MyApp1
resource "google_compute_region_instance_template" "myapp1_v2" {
  name        = "${local.name}-myapp1-template-v2"
  description = "This template is used to create V2 version of MyApp1 server instances."  
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
  instance_description = "MyApp1 VM Instances"
  machine_type         = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  # Create a new boot disk from an image
  disk {
    source_image      = data.google_compute_image.my_image.self_link
    auto_delete       = true
    boot              = true
  }
  # Network Info
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/v2-app1-webserver-install.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}
```

## Step-04: c6-03-app1-mig.tf
- Update the **version** block with new instance template (V2 version)
- Add **update_policy** block
```hcl
# Resource: Managed Instance Group
resource "google_compute_region_instance_group_manager" "myapp1" {
  name                       = "${local.name}-myapp1-mig"
  base_instance_name         = "${local.name}-myapp1"
  region                     = var.gcp_region1
  distribution_policy_zones  = data.google_compute_zones.available.names
  # Instance Template
  version {
    # V1 Version
    instance_template = google_compute_region_instance_template.myapp1.id
    # V2 Version
    #instance_template = google_compute_region_instance_template.myapp1_v2.id
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
  # Update Policy
  update_policy {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = length(data.google_compute_zones.available.names)
    max_unavailable_fixed          = length(data.google_compute_zones.available.names)
    replacement_method             = "SUBSTITUTE"
    # min_ready_sec                  = 50 #   (BETA Parameter)
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
1. Static IP
2. Load Balancer
3. MIG
4. VM Instnaces (Should not have external ip assigned)
5. Curl Test (V1 version of application will be displayed)
```t
# Curl test
curl <http://LOAD-BALANCER-IP>
curl 146.148.91.239
while true; do curl 146.148.91.239; sleep 1; done
```

## Step-07: c6-03-app1-mig.tf: Update V2 Instance template
- Comment V1 version and Uncomment V2 version
```hcl
  # Instance Template
  version {
    # V1 Version
    #instance_template = google_compute_region_instance_template.myapp1.id
    # V2 Version
    instance_template = google_compute_region_instance_template.myapp1_v2.id
  }
```

## Step-08: Execute Terraform Commands to apply new V2 version
```t
# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply
```

# Step-09: Verify Resources
1. Static IP
2. Load Balancer
3. MIG
4. VM Instnaces (Should not have external ip assigned)
5. Curl Test (V2 version of application will be displayed)
```t
# Curl test
curl <http://LOAD-BALANCER-IP>
curl 146.148.91.239
while true; do curl 146.148.91.239; sleep 1; done
```

## Step-10: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```

## Step-11: c6-03-app1-mig.tf: Rollback V1 Instance template
- Comment V2 version and Uncomment V1 version
- This will help students to implement this demo step by step in order without any issues. 
```hcl
  # Instance Template
  version {
    # V1 Version
    instance_template = google_compute_region_instance_template.myapp1.id
    # V2 Version
    #instance_template = google_compute_region_instance_template.myapp1_v2.id
  }
```



