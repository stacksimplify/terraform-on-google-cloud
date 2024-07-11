# Terraform Output Values
output "vpc_id" {
  description = "VPC ID"
  value = google_compute_network.myvpc.id 
}
output "subnet_id" {
  description = "Subnet ID"
  value = google_compute_subnetwork.mysubnet.id   
}
output "vm_external_ip" {
  description = "VM External IPs"
  #value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
  value = module.myvminstance.vm_external_ip
}
