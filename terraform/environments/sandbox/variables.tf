variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hams"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "tls_secret_name" {
  description = "Name of the TLS secret"
  type        = string
  default     = "turncert"
}

variable "tls_crt_content" {
  description = "Content of the TLS certificate"
  type        = string
}

variable "tls_key_content" {
  description = "Content of the TLS private key"
  type        = string
}
