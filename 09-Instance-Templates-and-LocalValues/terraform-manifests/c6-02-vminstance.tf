# Resource Block: Create a Compute Engine VM instance
resource "google_compute_instance_from_template" "myapp1" {
 # Meta-Argument: for_each
  for_each = toset(data.google_compute_zones.available.names)
  name         = "${local.name}-myapp1-vm-${each.key}"  
  zone        = each.key # You can also use each.value because for list items each.key == each.value
  source_instance_template = google_compute_region_instance_template.myapp1.self_link
}