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
