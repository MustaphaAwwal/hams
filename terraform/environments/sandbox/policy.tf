resource "aws_iam_policy" "ebs_csi_policy" {
  name        = "EBSCSIDriverPolicy"
  description = "IAM Policy that allows the CSI driver service account to create tags."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateTags"
        ]
        Effect = "Allow"
        "Resource" : [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
