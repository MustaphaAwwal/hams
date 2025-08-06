provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module from AWS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, i + length(var.availability_zones))]

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "sandbox" # Use single NAT Gateway for sandbox to reduce costs
  one_nat_gateway_per_az = var.environment == "live"    # Use multiple NAT Gateways for production

  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS specific tags
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# EKS Module from AWS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.cluster_version

  # Enable public access for easier management
  endpoint_public_access = true

  # Enable permissions for cluster creator
  enable_cluster_creator_admin_permissions = true

  # Enable auto-compute configuration
  compute_config = {
    enabled = true
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Locals for naming consistency
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
}
