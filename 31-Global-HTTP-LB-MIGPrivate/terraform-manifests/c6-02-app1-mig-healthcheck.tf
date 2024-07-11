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




