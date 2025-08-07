locals {
  name = "${var.project_name}-sandbox"
}



# EKS Auto Mode Configuration
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.name}-eks"
  kubernetes_version = var.cluster_version

  # Enable public access for easier management in sandbox
  endpoint_public_access = true

  # Enable permissions for cluster creator
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  node_security_group_id = aws_security_group.eks_node_sg.id

  # Common tags
  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}


# add-ons

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_argocd = true
  enable_cert_manager = true

  aws_load_balancer_controller = {
    values = [
      <<-EOT
        clusterName: ${module.eks.cluster_name}
        region: ${var.aws_region}
        vpcId: ${module.vpc.vpc_id}
      EOT
    ]
  }


  tags = {
    Environment = "sandbox"
  }
}

# LiveKit Egress S3 Bucket
resource "aws_s3_bucket" "livekit_egress" {
  bucket = "livekit-eggress-bucket"

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}

resource "aws_s3_bucket_versioning" "livekit_egress_versioning" {
  bucket = aws_s3_bucket.livekit_egress.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "livekit_egress_encryption" {
  bucket = aws_s3_bucket.livekit_egress.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "livekit_egress_block" {
  bucket                  = aws_s3_bucket.livekit_egress.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
