variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hams"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "sandbox"
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



variable "redis_config" {
  description = "Complete Redis configuration object"
  type = object({
    # Basic configuration
    name_prefix = string
    description = string
    # Engine configuration
    engine_version = optional(string, "7.0")
    node_type = optional(string, "cache.t3.medium")
    num_cache_clusters = optional(number, 2) # 1 primary + 1 replica
    # Network configuration
    # High Availability
    multi_az_enabled = optional(bool, true)
    automatic_failover_enabled = optional(bool, true)
    # Backup configuration
    backup = optional(object({
      snapshot_retention_limit = optional(number, 7)
      snapshot_window = optional(string, "03:00-05:00")
      maintenance_window = optional(string, "sun:05:00-sun:07:00")
    }), {})
    # Tags
    tags = optional(map(string), {})
  })
  
  # Default configuration
  default = {
    name_prefix = "livekit"
    description = "Redis cluster for application caching"
    engine_version = "7.0"
    node_type = "cache.t3.medium"
    num_cache_clusters = 2
    multi_az_enabled = true
    automatic_failover_enabled = true
    backup = {
      snapshot_retention_limit = 7
      snapshot_window = "03:00-05:00"
      maintenance_window = "sun:05:00-sun:07:00"
    }
    tags = {}
  }
  
  # Validation rules
  validation {
    condition = var.redis_config.num_cache_clusters >= 1 && var.redis_config.num_cache_clusters <= 6
    error_message = "num_cache_clusters must be between 1 and 6 for non-cluster mode."
  }
  
  validation {
    condition = contains(["7.0", "6.2", "6.0", "5.0.6"], var.redis_config.engine_version)
    error_message = "engine_version must be a valid Redis version."
  }
  
  validation {
    condition = var.redis_config.automatic_failover_enabled == false || var.redis_config.num_cache_clusters > 1
    error_message = "automatic_failover_enabled requires num_cache_clusters > 1."
  }
}