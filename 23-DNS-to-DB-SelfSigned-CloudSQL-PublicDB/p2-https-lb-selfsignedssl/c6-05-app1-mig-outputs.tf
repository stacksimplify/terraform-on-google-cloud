# Terraform Output Values
output "myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.myapp1.id 
}

output "myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.myapp1.instance_group
}

output "myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.myapp1.self_link
}

output "myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.myapp1.status
}