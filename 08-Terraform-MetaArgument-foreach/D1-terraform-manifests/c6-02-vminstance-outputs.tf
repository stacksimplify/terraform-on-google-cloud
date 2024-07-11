# Terraform Output Values
# Output - For with list
output "for_output_list1" {
  description = "For Loop with List"
  value = [for instance in google_compute_instance.myapp1: instance.name]
}

# Output - For Loop with Map 
output "for_output_map1" {
  description = "For Loop with Map1"
  value = {for instance in google_compute_instance.myapp1: instance.name => instance.instance_id}
}

# Output - VM External IPs
output "vm_external_ips" {
  description = "VM Instance Names -> VM External IPs"
  value = {for instance in google_compute_instance.myapp1: instance.name => instance.network_interface.0.access_config.0.nat_ip}
}
