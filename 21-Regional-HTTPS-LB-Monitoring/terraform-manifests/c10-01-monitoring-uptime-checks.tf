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