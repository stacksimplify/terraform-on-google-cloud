# Module Block: Create a single Compute Engine instance
module "myvminstance" {
  source  = "../../modules/vminstance"
  vminstance_name = "${local.name}-myapp1"
  machine_type = var.machine_type
  zone = "us-central1-a"
  firewall_tags = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0]]
  subnetwork = google_compute_subnetwork.mysubnet.id
}

