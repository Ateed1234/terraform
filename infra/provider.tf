# GCP Provider

provider "google" {
    credentials = file(var.gcp_sa_key)
    project = var.gcp_project_id
    region = var.gcp_region  
}

