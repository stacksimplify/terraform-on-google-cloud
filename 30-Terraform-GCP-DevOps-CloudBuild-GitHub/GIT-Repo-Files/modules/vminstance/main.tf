# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = var.vminstance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.firewall_tags
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size = 10
      #size = 20
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  network_interface {
    subnetwork = var.subnetwork   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}