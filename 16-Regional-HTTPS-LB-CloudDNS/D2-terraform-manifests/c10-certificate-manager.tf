# Resource: Certificate Manager DNS Authorization
resource "google_certificate_manager_dns_authorization" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-myapp1-dns-authorization"
  description = "myapp1 dns authorization"
  domain      = "${local.mydomain}"
}

# Resource: Certificate manager certificate
resource "google_certificate_manager_certificate" "myapp1" {
  location    = var.gcp_region1
  name        = "${local.name}-myapp1-ssl-certificate"
  description = "${local.name} Certificate Manager SSL Certificate"
  scope       = "DEFAULT"
  labels = {
    env = "dev"
  }
  managed {
    domains = [
      google_certificate_manager_dns_authorization.myapp1.domain
      ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.myapp1.id
      ]
  }
}


# Resource: DNS record to be created in DNS zone for DNS Authorization
resource "google_dns_record_set" "myapp1_cname" {
  #project      = "kdaida123"
  managed_zone = "${local.dns_managed_zone}"
  name         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.myapp1.dns_resource_record[0].data]
}




/*
# gcloud Commands 
gcloud certificate-manager maps list
gcloud certificate-manager maps entries list --map="app3-certmap1"
gcloud certificate-manager maps entries describe app3-first-entry --map="app3-certmap1"
 
gcloud certificate-manager maps entries describe CERTIFICATE_MAP_ENTRY_NAME \
   --map="CERTIFICATE_MAP_NAME"

//certificatemanager.googleapis.com/projects/{project}/locations/{location}/certificateMaps/{resourceName}.

# Certiticate List
gcloud certificate-manager certificates list
gcloud certificate-manager certificates describe hr-dev-ssl-certificate


# Attach cert using gcloud
gcloud compute target-https-proxies list
gcloud compute target-https-proxies update PROXY_NAME  --certificate-map="CERTIFICATE_MAP_NAME"
gcloud compute target-https-proxies update hr-dev-mylb-https-proxy  --certificate-map="app3-certmap1"

gcloud compute target-https-proxies describe hr-dev-mylb-https-proxy
*/
