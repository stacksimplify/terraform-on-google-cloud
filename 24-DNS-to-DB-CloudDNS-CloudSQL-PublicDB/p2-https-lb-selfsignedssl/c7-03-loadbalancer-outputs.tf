output "mylb_static_ip_address" {
  description = "The static IP address of the load balancer."
  value       = google_compute_address.mylb.address
}

output "mylb_backend_service_self_link" {
  description = "The self link of the backend service."
  value       = google_compute_region_backend_service.mylb.self_link
}

output "mylb_url_map_self_link" {
  description = "The self link of the URL map."
  value       = google_compute_region_url_map.mylb.self_link
}

output "mylb_target_https_proxy_self_link" {
  description = "The self link of the target HTTPS proxy."
  value       = google_compute_region_target_https_proxy.mylb.self_link
}

output "mylb_forwarding_rule_ip_address" {
  description = "The IP address of the forwarding rule."
  value       = google_compute_forwarding_rule.mylb.ip_address
}

