resource "kubernetes_namespace" "livekit" {
  metadata {
    name = "livekit"
  }
}

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

resource "kubernetes_service_account" "livekit_egress" {
  metadata {
    name      = "livekit-egress"
    namespace = kubernetes_namespace.livekit.id
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.livekit_egress_sa.arn
    }
  }
}

# # LiveKit Server Helm Release
# resource "helm_release" "livekit_server" {
#   name       = "livekit-server"
#   repository = "https://helm.livekit.io"
#   chart      = "livekit-server"
#   namespace  = "livekit"
#   values     = [file("${path.module}/helm-values/livekit-server-values.yaml")]
#   depends_on = [module.eks]
# }

# # LiveKit Egress Helm Release
# resource "helm_release" "livekit_egress" {
#   name       = "livekit-egress"
#   repository = "https://helm.livekit.io"
#   chart      = "livekit-egress"
#   namespace  = "livekit"
#   values     = [file("${path.module}/helm-values/livekit-egress-values.yaml")]
#   set {
#     name  = "serviceAccount.name"
#     value = "livekit-egress-sa-role"
#   }
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
#   set {
#       name  = "s3.bucket"
#       value = aws_s3_bucket.livekit_egress.bucket
#   }
#   depends_on = [module.eks, aws_s3_bucket.livekit_egress, kubernetes_service_account.livekit_egress]
# }
