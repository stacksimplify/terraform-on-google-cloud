# Terraform Datasources
/* Datasource: Get a list of Google 
Compute zones that are UP in a region */
data "google_compute_zones" "available" {    
  status = "UP"
}

# Output value
output "compute_zones" {
  description = "List of compute zones"
  value = data.google_compute_zones.available.names
}
