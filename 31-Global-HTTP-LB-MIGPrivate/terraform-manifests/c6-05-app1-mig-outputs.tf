# Terraform Output Values: 
# MIG Outputs Region1
output "region1_myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.region1_myapp1.id 
}

output "region1_myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.region1_myapp1.instance_group
}

output "region1_myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.region1_myapp1.self_link
}

output "region1_myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.region1_myapp1.status
}

# MIG Outputs Region2
output "region2_myapp1_mig_id" {
  value = google_compute_region_instance_group_manager.region2_myapp1.id 
}

output "region2_myapp1_mig_instance_group" {
  value = google_compute_region_instance_group_manager.region2_myapp1.instance_group
}

output "region2_myapp1_mig_self_link" {
  value = google_compute_region_instance_group_manager.region2_myapp1.self_link
}

output "region2_myapp1_mig_status" {
  value = google_compute_region_instance_group_manager.region2_myapp1.status
}