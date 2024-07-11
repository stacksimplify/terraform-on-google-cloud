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

