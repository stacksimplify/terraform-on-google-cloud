# Firewall Rule: SSH
resource "google_compute_firewall" "fw_ssh" {
  name = "${local.name}-fwrule-allow-ssh22"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  #network       = google_compute_network.myvpc.id 
  network       = data.terraform_remote_state.project1.outputs.vpc_id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-tag"]
}

# Firewall Rule: HTTP Port 80, 8080
resource "google_compute_firewall" "fw_http" {
  name = "${local.name}-fwrule-allow-http80"
  allow {
    ports    = ["80", "8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  #network       = google_compute_network.myvpc.id 
  network       = data.terraform_remote_state.project1.outputs.vpc_id  
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver-tag"]
}

# Firewall rule: Allow Health checks
resource "google_compute_firewall" "fw_health_checks" {
  name    = "fwrule-allow-health-checks"
  #network = google_compute_network.myvpc.id 
  network       = data.terraform_remote_state.project1.outputs.vpc_id  
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["allow-health-checks"]
}