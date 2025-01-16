terraform {
  required_providers { google = {
    source = "hashicorp/google"
  version = "6.16.0" } }
}

provider "google" {
  project = "terraform-demo-448015"
  region  = "SOUTHAMERICA-EAST1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "terraform-demo-448015-terra-bucket"
  location      = "SOUTHAMERICA-EAST1"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }

  }
}