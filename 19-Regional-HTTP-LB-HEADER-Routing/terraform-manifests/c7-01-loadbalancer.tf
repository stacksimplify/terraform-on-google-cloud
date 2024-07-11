# Resource: Reserve Regional Static IP Address
resource "google_compute_address" "mylb" {
  name   = "${local.name}-mylb-regional-static-ip"
  region = var.gcp_region1
}

# Resource: Regional Health Check
resource "google_compute_region_health_check" "mylb" {
  name                = "${local.name}-mylb-myapp1-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}

# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "myapp1" {
  name                  = "${local.name}-myapp1-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group = google_compute_region_instance_group_manager.myapp1.instance_group
    capacity_scaler = 1.0
    balancing_mode = "UTILIZATION"
  }
}

# Resource: Regional Backend Service
resource "google_compute_region_backend_service" "myapp2" {
  name                  = "${local.name}-myapp2-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group = google_compute_region_instance_group_manager.myapp2.instance_group
    capacity_scaler = 1.0
    balancing_mode = "UTILIZATION"
  }
}


# Resource: Regional URL Map
resource "google_compute_region_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_region_backend_service.myapp1.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "my-path-routing-1"
  }

  path_matcher {
    name            = "my-path-routing-1"
    # App1: No appname, routes to default which is myapp1
    default_service = google_compute_region_backend_service.myapp1.id
    
    # App1 - Route based on Header
    route_rules {
      priority = 1
      service = google_compute_region_backend_service.myapp1.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        header_matches {
          header_name = "appname"
          exact_match = "myapp1"
        }
      }
    }
    # App2 - Route based on Header
    route_rules {
      priority = 2
      service = google_compute_region_backend_service.myapp2.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        header_matches {
          header_name = "appname"
          exact_match = "myapp2"
        }
      }
    }
  }
}
  
# Resource: Regional HTTP Proxy
resource "google_compute_region_target_http_proxy" "mylb" {
  name   = "${local.name}-mylb-http-proxy"
  url_map = google_compute_region_url_map.mylb.self_link
}


# Resource: Regional Forwarding Rule
resource "google_compute_forwarding_rule" "mylb" {
  name        = "${local.name}-mylb-forwarding-rule"
  target      = google_compute_region_target_http_proxy.mylb.self_link
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  network = google_compute_network.myvpc.id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}










