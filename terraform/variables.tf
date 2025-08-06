variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"  # Can be overridden per environment
}

variable "environment" {
  description = "Environment name (sandbox/live)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "hams"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}
