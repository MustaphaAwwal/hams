variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "MustaphaAwwal"  # Replace with your org/username
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "hams"
}

variable "iam_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-role"
}

variable "provider_url" {
  description = "GitHub's OIDC provider URL"
  type        = string
  default     = "token.actions.githubusercontent.com"
}
