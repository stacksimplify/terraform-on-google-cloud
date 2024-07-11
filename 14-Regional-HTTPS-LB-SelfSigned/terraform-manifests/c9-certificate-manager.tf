# Resource: Certificate manager certificate
resource "google_certificate_manager_certificate" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-ssl-certificate"
  description = "${local.name} Certificate Manager SSL Certificate"
  scope       = "DEFAULT"
  self_managed {
    pem_certificate = file("${path.module}/self-signed-ssl/app1.crt")
    pem_private_key = file("${path.module}/self-signed-ssl/app1.key")
  }
  labels = {
    env = local.environment
  }
}

/*
# Certiticate List
gcloud certificate-manager certificates list
gcloud certificate-manager certificates describe hr-dev-ssl-certificate


# Attach cert using gcloud
gcloud compute target-https-proxies list
gcloud compute target-https-proxies update PROXY_NAME  --certificate-map="CERTIFICATE_MAP_NAME"
gcloud compute target-https-proxies update hr-dev-mylb-https-proxy  --certificate-map="app3-certmap1"
gcloud compute target-https-proxies describe hr-dev-mylb-https-proxy
*/
