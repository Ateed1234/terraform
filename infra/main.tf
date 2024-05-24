# Bucket to store website
resource "google_storage_bucket" "basura" {
  name = "ejemplo-de-website-ateed"
  location = "EU"
}

# Make new objects public
resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.el_site.name
  bucket = google_storage_bucket.basura.name
  role = "READER"
  entity = "allUsers"
}

# Upload index.html to bucket
resource "google_storage_bucket_object" "el_site" {
  name = "index.html"
  source = "../website/index.html"
  bucket = google_storage_bucket.basura.name
}

#Reserving a static externañ IP 
resource "google_compute_global_address" "IP_terraform_lb" {
  name = "terra-lp-IP"
}

# Get the managed DNS zone
data "google_dns_managed_zone" "dns_zone" {
    name = "ateedmuhammad-com"
}

# Add the ip to the DNS
resource "google_dns_record_set" "website" {
  name = "website.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl = 300
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas = [google_compute_global_address.IP_terraform_lb.address]
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website-backend" {
  name = "website-bucket"
  bucket_name = google_storage_bucket.basura.name
  description = "Contains files needed for the website"
  enable_cdn = true
}

# GCP URL MAP
resource "google_compute_url_map" "website" {
  name = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_bucket.website-backend.self_link
  }
}

#GCP HTTP Proxy
resource "google_compute_target_http_proxy" "lb_terraform" {
  name = "website-target-lb"
  url_map = google_compute_url_map.website.self_link
}

#GCP FOrwaring rule
resource "google_compute_global_forwarding_rule" "default" {
  name = "website-forwardig-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.IP_terraform_lb.address
  ip_protocol = "TCP"
  port_range = "80"
  target = google_compute_target_http_proxy.lb_terraform.self_link
}

