variable "name" {
  description = "Name of the service account and IAM role"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
}

variable "oidc_url" {
  description = "EKS OIDC provider URL (without https://)"
  type        = string
}

variable "oidc_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}

variable "s3_bucket_arn" {
  description = "Name of the S3 bucket to allow access to"
  type        = string
}

