# HAMS Infrastructure

This repository contains the Terraform configurations for the HAMS (Healthcare Availability Monitoring System) infrastructure.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or newer
- GitHub repository with Actions enabled

## Initial Setup

### 1. Set up Terraform Backend

Before you can use this Terraform configuration, you need to create the S3 backend and DynamoDB table for state management:

```bash
cd terraform/global/s3-backend
terraform init
terraform apply
```

After the backend is created, update each environment's backend configuration in their respective `backend.tf` files:

```hcl
terraform {
  backend "s3" {
    bucket         = "hams-terraform-state"
    key            = "env/<environment>/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "hams-terraform-locks"
    encrypt        = true
  }
}
```

### 2. GitHub OIDC Configuration

To enable GitHub Actions to deploy to AWS, we use OpenID Connect (OIDC) for secure authentication. The configuration is managed through Terraform in the `terraform/global/iam` directory.

1. Update the GitHub organization and repository name in `terraform/global/iam/main.tf`:

```hcl
locals {
  github_org  = "your-org"     # Replace with your GitHub organization/username
  github_repo = "hams"         # Replace with your repository name
}
```

2. Apply the IAM configuration:

```bash
cd terraform/global/iam
terraform init
terraform apply
```

This will create:
- An IAM OIDC Identity Provider for GitHub
- An IAM Role with the necessary trust policy
- Required policy attachments for Terraform management

3. Note the role ARN from the output:
```bash
terraform output github_actions_role_arn
```

4. Update GitHub Actions workflow to use OIDC:

```yaml
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::<account-id>:role/<role-name>
          aws-region: us-west-2
```

## Repository Structure

```
terraform/
├── environments/
│   ├── live/
│   └── sandbox/
├── global/
│   ├── iam/
│   └── s3-backend/
└── modules/
    └── core-services/
```

## Security Notes

- The S3 bucket has versioning enabled to protect against accidental state file deletion
- Server-side encryption is enabled by default
- DynamoDB table is used for state locking
- GitHub OIDC provides secure, temporary credentials without storing AWS secrets
- Current IAM configuration uses AdministratorAccess policy - consider restricting this in production

## Deployment Order

When setting up the infrastructure for the first time, follow this order:

1. Create S3 backend and DynamoDB table:
```bash
cd terraform/global/s3-backend
terraform init
terraform apply
```

2. Set up GitHub OIDC authentication:
```bash
cd terraform/global/iam
terraform init
terraform apply
```

3. Deploy environment-specific infrastructure:
```bash
cd terraform/environments/sandbox  # or live
terraform init
terraform apply
```
