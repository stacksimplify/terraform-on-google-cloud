data "google_compute_image" "my_image" {
  # Debian
  project = "debian-cloud"  
  family  = "debian-12"
  
  # CentOs
  #project = "centos-cloud"  
  #family  = "centos-stream-9"

  # RedHat
  #project = "rhel-cloud" 
  #family  = "rhel-9"
  
  # Ubuntu
  #project = "ubuntu-os-cloud"
  #family  = "ubuntu-2004-lts"

  # Microsoft
  #project = "windows-cloud"
  #family  = "windows-2022"

  # Rocky Linux
  #project = "rocky-linux-cloud"
  #family  = "rocky-linux-8"  
}


# Outputs
output "id" {
  value = data.google_compute_image.my_image.id
}


output "self_link" {
  value = data.google_compute_image.my_image.self_link
}

output "name" {
  value = data.google_compute_image.my_image.name
}

output "family" {
  value = data.google_compute_image.my_image.family
}

output "image_id" {
  value = data.google_compute_image.my_image.image_id
}

output "status" {
  value = data.google_compute_image.my_image.status
}

output "licenses" {
  value = data.google_compute_image.my_image.licenses
}

output "description" {
  value = data.google_compute_image.my_image.description
}

output "project" {
  value = data.google_compute_image.my_image.project
}

output "source_image_id" {
  value = data.google_compute_image.my_image.source_image_id
}

