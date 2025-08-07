variable "domain_name" {
  description = "The root domain name for Route53 hosted zone."
  type        = string
  default     = "awwalmustapha.online"
}

variable "livekit_subdomain" {
  description = "The subdomain for LiveKit."
  type        = string
  default     = "livekit.awwalmustapha.online"
}

variable "turn_subdomain" {
  description = "The subdomain for TURN."
  type        = string
  default     = "turn.awwalmustapha.online"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
  
}