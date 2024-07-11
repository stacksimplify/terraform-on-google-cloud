# Resource: MIG Autoscaling: Region1
resource "google_compute_region_autoscaler" "region1_myapp1" {
  region = var.gcp_region1
  name   = "${local.name}-${var.gcp_region1}-mig-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.region1_myapp1.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60  
    cpu_utilization {
      target = 0.9
    }
  }
}

# Resource: MIG Autoscaling: Region2
resource "google_compute_region_autoscaler" "region2_myapp1" {
  region = var.gcp_region2
  name   = "${local.name}-${var.gcp_region2}-mig-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.region2_myapp1.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60  
    cpu_utilization {
      target = 0.9
    }
  }
}
