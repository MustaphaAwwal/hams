provider "aws" {
  region = var.aws_region
  profile = "awwal"
}

# Create the OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.provider_url}"

  client_id_list = ["sts.amazonaws.com"]

}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = var.iam_role_name

  # Trust relationship policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "${var.provider_url}:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
          StringEquals = {
            "${var.provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach AdministratorAccess policy to the role
# Note: In production, you should limit this to only required permissions
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Outputs
output "github_actions_role_arn" {
  description = "ARN of IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_openid_connect_provider_arn" {
  description = "ARN of GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
