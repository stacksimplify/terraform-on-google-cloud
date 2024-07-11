# Resource: Reserve Regional Static IP Address
resource "google_compute_address" "mylb" {
  name   = "${local.name}-mylb-regional-static-ip"
  region = var.gcp_region1
}

# Resource: Regional Health Check
resource "google_compute_region_health_check" "mylb" {
  name                = "${local.name}-mylb-myapp1-health-check"
  check_interval_sec  = 20
  timeout_sec         = 10
  healthy_threshold   = 3
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/login"
    port         = 8080
  }
}

# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "mylb" {
  name                  = "${local.name}-myapp1-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.mylb.self_link]
  port_name             = "appserver"
  session_affinity      = "GENERATED_COOKIE"
  backend {
    group = google_compute_region_instance_group_manager.myapp1.instance_group
    capacity_scaler = 1.0
    balancing_mode = "UTILIZATION"
  }
}

# Resource: Regional URL Map
resource "google_compute_region_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_region_backend_service.mylb.self_link
}
 

# Resource: Regional HTTPS Proxy
resource "google_compute_region_target_https_proxy" "mylb" {
  name   = "${local.name}-mylb-https-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
  certificate_manager_certificates = [ google_certificate_manager_certificate.myapp1.id ]
}


# Resource: Regional Forwarding Rule
resource "google_compute_forwarding_rule" "mylb" {
  name        = "${local.name}-mylb-forwarding-rule"
  target      = google_compute_region_target_https_proxy.mylb.self_link
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  #network = google_compute_network.myvpc.id
  network = data.terraform_remote_state.project1.outputs.vpc_id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  #depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}










