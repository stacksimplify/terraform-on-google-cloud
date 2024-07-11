# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "cloudsql_publicdb" {
  backend = "gcs"
  config = {
    bucket = "gcplearn9-tfstate"
    prefix = "cloudsql/publicdb"
  }
}

output "datasource_cloudsql_publicip" {
  value = data.terraform_remote_state.cloudsql_publicdb.outputs.cloudsql_db_public_ip
}