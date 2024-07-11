---
title: GCP Google Cloud Platform - Cloud Monitoring
description: Learn to implement Cloud Monitoring using Terraform on Google Cloud Platform
---

## Step-01: Introduction
- Implement Cloud Monitoring

## Step-02: COPY from section 20-Regional-HTTPS-LB-Logging
- COPY from section 20-Regional-HTTPS-LB-Logging

## Step-03: c2-01-variables.tf: Define additional variables
```hcl
# GCP Notification Email for Cloud Monitoring
variable "gcp_notification_email" {
  description = "GCP Notification email"
  type =  string
  default = "abcd1234@gmail.com"
}
```

## Step-04: Update or Review terraform.tfvars
```hcl
gcp_project     = "gcplearn9" # This is project ID
gcp_region1     = "us-central1"
machine_type    = "e2-micro"
environment     = "dev"
business_divsion = "hr"
gcp_notification_email = "stacksimplify@gmail.com"
```

## Step-05: c10-01-monitoring-uptime-checks.tf
```hcl
# Resource: Notification channel for alerting
resource "google_monitoring_notification_channel" "email_channel" {
  display_name = "${local.name} Email Notification Channel"
  type         = "email"
  labels = {
    email_address = var.gcp_notification_email
  }
}

# Resource: Uptime check
resource "google_monitoring_uptime_check_config" "https" {
  display_name = "${local.name}-myapp1-lb-https-uptime-check"
  timeout = "60s"

  http_check {
    path = "/index.html"
    port = "443"
    use_ssl = true
    #validate_ssl = true # We are using self-signed, so don't use this
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project # Provide Project ID here, my project name and ID is same used var.gcp_project
      host = google_compute_address.mylb.address
    }
  }
  content_matchers {
    content = "Welcome"
  }
}

# Resource: Alert policy for the uptime check
resource "google_monitoring_alert_policy" "lb_uptime_alert" {
  display_name = "${local.name}-myapp1-lb-uptime-alert"
  combiner     = "OR"

  conditions {
    display_name = "${local.name}-lb-uptime-condition"
    condition_threshold {
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND resource.label.\"project_id\"=\"${var.gcp_project}\" AND resource.label.\"host\"=\"${google_compute_address.mylb.address}\""
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_FRACTION_TRUE"
        cross_series_reducer = "REDUCE_MEAN"
      }
      comparison    = "COMPARISON_LT"
      threshold_value = 1
      duration      = "0s"
    }
  }
  severity = "CRITICAL"
  documentation {
    content  = "This alert policy monitors the uptime of the load balancer. It checks whether the specified URL is up and running. If the uptime check fails, an alert is triggered and a notification is sent to the specified email channel."
    mime_type = "text/markdown"
    subject  = "${local.name} MyApp1 Load Balancer Uptime Alert"
  }
  notification_channels = [google_monitoring_notification_channel.email_channel.id]
}
```
### Metric Filter in readable and easy to understand format
```t
"metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\"
         AND resource.type=\"uptime_url\"
         AND resource.label.\"project_id\"=\"${var.gcp_project}\"
         AND resource.label.\"host\"=\"${google_compute_address.mylb.address}\""

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
6. Verify Cloud Monitoring - Uptime checks
7. Verify Cloud Monitoring - Alert Policy
8. Restart VMs to review incidents triggered
```t
# Access HTTPS URL
https://<LOAD-BALANCER-IP>
https://<LOAD-BALANCER-IP>/app1/index.html

# Curl Test in a loop
while true; do curl -k https://34.72.225.55/app1/index.html; sleep 1; done

# Cloud Logging Query
resource.type="gce_instance"
(log_id("nginx_access") OR log_id("nginx_error"))

# Cloud Monitoring
Goto Cloud Monitoring -> Detect -> Uptime checks

# Restart VMs
Goto Compute Engine -> Instance Groups -> hr-dev-myapp1-mig -> Restart/replace VMs 

# Alert Policy and Incidents
Goto Cloud Monitoring -> Detect -> Alerting -> hr-dev-myapp1-lb-https-uptime-check
1. Verify Incidents
2. Verify Incident email: Alert firing
3. Verify Incident email: Alert recovered
```

## Step-08: Review Nginx Metrics
- Go to Metrics Explorer -> Select Nginx Metrics for a VM Instance
  - workload/nginx.connections_accepted
  - workload.googleapis.com/nginx.connections_current
  - workload.googleapis.com/nginx.connections_handled
  - workload.googleapis.com/nginx.requests
- **Important Note:** Using Nginx stub_status module we are collecting and sending these metrics from Nginx to Cloud Monitoring

## Step-09: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve
```
