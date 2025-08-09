data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.name}"]
    }
  }
}
