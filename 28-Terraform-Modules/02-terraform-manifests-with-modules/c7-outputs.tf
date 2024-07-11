# Terraform Output Values
output "vpc_id" {
  description = "VPC ID"
  #value = google_compute_network.myvpc.id 
  value = module.vpc.network_id
}
output "subnet_id" {
  description = "Subnet ID"
  #value = google_compute_subnetwork.mysubnet.id   
  value = module.vpc.subnets_ids[0]
}
output "vm_external_ip" {
  description = "VM External IPs"
  value = google_compute_instance.myapp1.network_interface.0.access_config.0.nat_ip
}
