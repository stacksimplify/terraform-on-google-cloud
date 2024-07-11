output "cloudsql_db_public_ip" {
  value = google_sql_database_instance.mydbinstance.public_ip_address
}