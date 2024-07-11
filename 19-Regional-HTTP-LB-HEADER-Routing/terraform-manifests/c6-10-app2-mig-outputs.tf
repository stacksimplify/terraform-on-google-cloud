# Terraform Output Values
output "myapp2_mig_id" {
  value = google_compute_region_instance_group_manager.myapp2.id 
}

output "myapp2_mig_instance_group" {
  value = google_compute_region_instance_group_manager.myapp2.instance_group
}

output "myapp2_mig_self_link" {
  value = google_compute_region_instance_group_manager.myapp2.self_link
}

output "myapp2_mig_status" {
  value = google_compute_region_instance_group_manager.myapp2.status
}