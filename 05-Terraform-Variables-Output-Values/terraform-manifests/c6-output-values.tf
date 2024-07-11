# Terraform Output Values
## ATTRIBUTES
output "vm_instanceid" {
  description = "VM Instance ID"
  value = google_compute_instance.myapp1.instance_id
}

output "vm_selflink" {
  description = "VM Instance Self link"
  value = google_compute_instance.myapp1.self_link
}

output "vm_id" {
  description = "VM ID"
  value = google_compute_instance.myapp1.id
}

output "vm_external_ip" {
  description = "VM External IPs"
  value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
}

## ARGUMENTS
output "vm_name" {
  description = "VM Name"
  value = google_compute_instance.myapp1.name
}

output "vm_machine_type" {
  description = "VM Machine Type"
  value = google_compute_instance.myapp1.machine_type
}