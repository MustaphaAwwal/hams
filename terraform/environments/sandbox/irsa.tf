# IRSA for LiveKit Egress
resource "aws_iam_role" "livekit_egress_sa" {
  name = "livekit-egress-sa-role"
  assume_role_policy = data.aws_iam_policy_document.livekit_egress_assume_role_policy.json
  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}

data "aws_iam_policy_document" "livekit_egress_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, ":oidc-provider/", ":sub")}:sub"
      values   = ["system:serviceaccount/livekit/livekit-egress"]
    }
  }
}

resource "aws_iam_role_policy" "livekit_egress_s3_policy" {
  name = "livekit-egress-s3-policy"
  role = aws_iam_role.livekit_egress_sa.id
  policy = data.aws_iam_policy_document.livekit_egress_s3_policy.json
}

data "aws_iam_policy_document" "livekit_egress_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.livekit_egress.arn,
      "${aws_s3_bucket.livekit_egress.arn}/*"
    ]
  }
}

module "loki_irsa" {
  source             = "./modules/irsa/s3"
  name               = "loki"
  namespace          = "observability"
  oidc_url           = "${replace(module.eks.oidc_provider_arn, ":oidc-provider/", ":sub")}:sub"
  oidc_arn           = module.eks.oidc_provider_arn
  s3_bucket_arn      = aws_s3_bucket.loki_logs.arn
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn, aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
