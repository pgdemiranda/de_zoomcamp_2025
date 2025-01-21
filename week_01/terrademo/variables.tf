variable "credentials" {
  description = "Credentials"
  default     = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "terraform-demo-448015"
}

variable "region" {
  description = "Project Region"
  default     = "SOUTHAMERICA-EAST1"
}

variable "location" {
  description = "Project Location"
  default     = "SOUTHAMERICA-EAST1"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "terraform-demo-448015-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}