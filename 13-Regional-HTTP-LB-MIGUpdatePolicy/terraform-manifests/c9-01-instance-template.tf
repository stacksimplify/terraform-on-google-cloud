# Google Compute Engine: Regional Instance Template V2 for MyApp1
resource "google_compute_region_instance_template" "myapp1_v2" {
  name        = "${local.name}-myapp1-template-v2"
  description = "This template is used to create V2 version of MyApp1 server instances."  
  tags        = [tolist(google_compute_firewall.fw_ssh.target_tags)[0], tolist(google_compute_firewall.fw_http.target_tags)[0], tolist(google_compute_firewall.fw_health_checks.target_tags)[0]]
  instance_description = "MyApp1 VM Instances"
  machine_type         = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  # Create a new boot disk from an image
  disk {
    source_image      = data.google_compute_image.my_image.self_link
    auto_delete       = true
    boot              = true
  }
  # Network Info
  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id 
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/v2-app1-webserver-install.sh")
  labels = {
    environment = local.environment
  }
  metadata = {
    environment = local.environment
  }
}


