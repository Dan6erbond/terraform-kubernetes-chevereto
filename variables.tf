variable "namespace" {
  description = "Namespace where Chevereto is deployed"
  type        = string
  default     = "default"
}

variable "image_registry" {
  description = "Image registry, e.g. gcr.io, docker.io"
  type        = string
  default     = "ghcr.io"
}

variable "image_repository" {
  description = "Image to start for this pod"
  type        = string
  default     = "chevereto/chevereto"
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "4.0"
}

variable "container_name" {
  description = "Name of the Chevereto container"
  type        = string
  default     = "chevereto"
}

variable "match_labels" {
  description = "Match labels to add to the Chevereto deployment, will be merged with labels"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the Chevereto deployment"
  type        = map(any)
  default     = {}
}

variable "storage_size" {
  description = "Storage size for the Chevereto PVC"
  type        = string
  default     = "10Gi"
}

variable "storage_class_name" {
  description = "Storage class to use for PVCs"
  type        = string
  default     = ""
}

variable "mariadb_host" {
  description = "MariaDB or MySQL hostname"
  type        = string
}

variable "mariadb_user" {
  description = "User for database"
  type        = string
}

variable "mariadb_password" {
  description = "Password for database"
  type        = string
}

variable "mariadb_port" {
  description = "Port for MariaDB or MySQL"
  type        = number
  default     = 3306
}

variable "mariadb_database" {
  description = "Database to use"
  type        = string
}

variable "host" {
  description = "Public facing hostname for Chevereto"
  type        = string
  default     = "localhost:80"
}

variable "host_path" {
  description = "Subpath for Chevereto"
  type        = string
  default     = "/"
}

variable "https" {
  description = "Is Chevereto deployed under HTTPS"
  type        = bool
  default     = true
}

variable "enable_s3" {
  description = "Whether S3 storage should be enabled"
  type        = bool
  default     = true
}

variable "s3_bucket" {
  description = "Bucket name for S3 storage"
  type        = string
  default     = ""
}

variable "s3_region" {
  description = "S3 storage region"
  type        = string
  default     = "us-west-2"
}

variable "s3_host" {
  description = "S3 host"
  type        = string
  default     = ""
}

variable "s3_url" {
  description = "Bucket URL for S3, including the bucket path e.g. <url>/bucket"
  type        = string
  default     = ""
}

variable "s3_access_key" {
  description = "S3 access key"
  type        = string
  default     = ""
}

variable "s3_secret_key" {
  description = "S3 secret key"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name of service to deploy"
  type        = string
  default     = "chevereto"
}

variable "service_type" {
  description = "Type of service to deploy"
  type        = string
  default     = "ClusterIP"
}
