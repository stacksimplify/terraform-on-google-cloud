output "vpc_id" {
  description = "VPC ID"
  value = google_compute_network.myvpc.id 
}

output "mysubnet_id" {
  description = "Subnet ID"
  value = google_compute_subnetwork.mysubnet.id 
}

output "regional_proxy_subnet_id" {
  description = "Regional Proxy Subnet ID"
  value = google_compute_subnetwork.regional_proxy_subnet.id 
}
 
 