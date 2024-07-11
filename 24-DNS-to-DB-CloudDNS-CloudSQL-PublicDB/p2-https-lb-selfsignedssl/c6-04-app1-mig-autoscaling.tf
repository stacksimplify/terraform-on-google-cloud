# Resource: MIG Autoscaling
resource "google_compute_region_autoscaler" "myapp1" {
  name   = "${local.name}-myapp1-autoscaler"
  target = google_compute_region_instance_group_manager.myapp1.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60 
    cpu_utilization {
      target = 0.9
    }
  }
}
