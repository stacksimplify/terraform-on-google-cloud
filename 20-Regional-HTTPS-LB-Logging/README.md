---
title: GCP Google Cloud Platform - Cloud Logging
description: Learn to implement Cloud Logging using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Implement Cloud Logging

## Step-02: COPY from section 14-Regional-HTTPS-LB-SelfSigned
- COPY from section 14-Regional-HTTPS-LB-SelfSigned

## Step-03: install-opsagent-webserver.sh
- [ngx_http_stub_status_module](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
```sh
#!/bin/bash
## SCRIPT-1: Webserver Steps ###############

# Step-1: Install Webserver
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
sudo mkdir -p /var/www/html/app1
HOSTNAME=$(hostname)
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/index.html
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Welcome to StackSimplify - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Google Cloud Platform - Demos</p> </body></html>" | sudo tee /var/www/html/app1/index.html

# Step-2: Create status.conf in Nginx
sudo tee /etc/nginx/conf.d/status.conf > /dev/null << EOF
server {
   listen 80;
   server_name 127.0.0.1;
   location /nginx_status {
       stub_status on;
       access_log off;
       allow 127.0.0.1;
       deny all;
   }
   location / {
       root /dev/null;
   }
}
EOF

# Step-3: Nginx reload
sudo service nginx reload

# Wait to ensure the webserver setup has completed
sleep 10

## SCRIPT-2: OPS Agent steps ###############

# Step-1: Install Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Step-2: Backup existing config.yaml file
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Step-3: Write the Ops Agent configuration for Nginx logs
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOF
metrics:
  receivers:
    nginx:
      type: nginx
      stub_status_url: http://127.0.0.1:80/nginx_status
  service:
    pipelines:
      nginx:
        receivers:
          - nginx
logging:
  receivers:
    nginx_access:
      type: nginx_access
    nginx_error:
      type: nginx_error
  service:
    pipelines:
      nginx:
        receivers:
          - nginx_access
          - nginx_error
EOF

# Step-4: Restart the Ops Agent to apply the new configuration
sudo service google-cloud-ops-agent restart
```

## Step-04: c6-06-service-account-logging.tf
```hcl
# Service Account
resource "google_service_account" "myapp1" {
  account_id   = "${local.name}-myapp1-mig-sa"
  display_name = "Service Account"
}

# Log Writer Permission to Service Account
resource "google_project_iam_member" "logging_role" {
  project = var.gcp_project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.myapp1.email}"
}

# Metric Writer Permission to Service Account
resource "google_project_iam_member" "monitoring_role" {
  project = var.gcp_project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.myapp1.email}"
}
```

## Step-05: c6-01-app1-instance-template.tf
- Update instance template with **service_account** block
```hcl
# Google Compute Engine: Regional Instance Template
resource "google_compute_region_instance_template" "myapp1" {
  name        = "${local.name}-myapp1-template"
  description = "This template is used to create MyApp1 server instances."
  #tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
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
    subnetwork = google_compute_subnetwork.mysubnet.id 
    /*access_config {
      # Include this section to give the VM an external IP address
    } */ 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/install-opsagent-webserver.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.myapp1.email
    scopes = ["cloud-platform"]
  }  
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

# Step-07: Verify Resources
1. Verify Load Balancer
2. Verify Certificate Manager SSL Certificate
3. Verify MIG
4. Verify Service Account
5. Verify Cloud Logging Logs
```t
# Access HTTPS URL
https://<LOAD-BALANCER-IP>
https://<LOAD-BALANCER-IP>/app1/index.html

# Curl Test in a loop
while true; do curl -k https://34.31.174.180/app1/index.html; sleep 1; done

# Cloud Logging Query
resource.type="gce_instance"
(log_id("nginx_access") OR log_id("nginx_error"))
```

## Step-08: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
