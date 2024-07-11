# Terraform Output Values
# Output - For with list
output "instance_names" {
  description = "VM Instance Names"
  value = [for instance in google_compute_instance_from_template.myapp1: instance.name]
}

# Output - For Loop with Map 
output "vm_instance_ids" {
  description = "VM Instances Names -> VM Instance IDs"
  value = {for instance in google_compute_instance_from_template.myapp1: instance.name => instance.instance_id}
}

output "vm_external_ips" {
  description = "VM Instance Names -> VM External IPs"
  value = {for instance in google_compute_instance_from_template.myapp1: instance.name => instance.network_interface.0.access_config.0.nat_ip}
}
