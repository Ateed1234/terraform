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
