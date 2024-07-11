# Resource: Regional URL Map for HTTP to HTTPS redirection
resource "google_compute_region_url_map" "http" {
  name = "${local.name}-myapp1-http-to-https-url-map"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# Resource: Regional Target HTTP Proxy for redirection
resource "google_compute_region_target_http_proxy" "http" {
  name   = "${local.name}-myapp1-http-to-https-proxy"
  url_map = google_compute_region_url_map.http.self_link
}

# Resource: Regional Forwarding Rule for HTTP to HTTPS redirection
resource "google_compute_forwarding_rule" "http" {
  name        = "${local.name}-myapp1-http-to-https-forwarding-rule"
  target      = google_compute_region_target_http_proxy.http.self_link
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address = google_compute_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED" # Creates new GCP LB (not classic)
  #network = google_compute_network.myvpc.id
  network = data.terraform_remote_state.project1.outputs.vpc_id
  # During the destroy process, we need to ensure LB is deleted first, before deleting VPC proxy-only subnet
  #depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
}
