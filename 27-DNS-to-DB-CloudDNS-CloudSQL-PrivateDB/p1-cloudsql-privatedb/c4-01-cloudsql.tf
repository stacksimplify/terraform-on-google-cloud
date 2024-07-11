# Random DB Name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}
# Resource: Cloud SQL Database Instance
resource "google_sql_database_instance" "mydbinstance" {
  # Create DB only after Private VPC connection is created
  depends_on = [ google_service_networking_connection.private_vpc_connection ]
  name = "${local.name}-mysql-${random_id.db_name_suffix.hex}"
  database_version = var.cloudsql_database_version
  project = var.gcp_project
  deletion_protection = false
  settings {
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"      # Other option is "ENTERPRISE_PLUS"
    availability_type = "ZONAL" # FOR HA use "REGIONAL"
    disk_autoresize = true
    disk_autoresize_limit = 20
    disk_size = 10
    disk_type = "PD_SSD"
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.myvpc.self_link      
    }
  }
}

# Resource: Cloud SQL Database Schema
resource "google_sql_database" "mydbschema" {
  name     = "webappdb"
  instance = google_sql_database_instance.mydbinstance.name
}

# Resource: Cloud SQL Database User
resource "google_sql_user" "users" {
  name     = "umsadmin"
  instance = google_sql_database_instance.mydbinstance.name
  host     = "%"
  password = "dbpassword11"
}



