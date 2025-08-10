# # LiveKit Server Helm Release
# resource "helm_release" "livekit_server" {
#   name       = "livekit-server"
#   repository = "https://helm.livekit.io"
#   chart      = "livekit-server"
#   namespace  = "livekit"
#   values     = [file("${path.module}/helm-values/livekit-server-values.yaml")]
#   depends_on = [module.eks]

#   set {
#     name  = "livekit.turn.secretName"
#     value = kubernetes_secret.livekit_turn_tls.metadata.0.name
#   }
# }

# # LiveKit Egress Helm Release
# resource "helm_release" "livekit_egress" {
#   name       = "egress"
#   repository = "https://helm.livekit.io"
#   chart      = "egress"
#   namespace  = "livekit"
#   values     = [file("${path.module}/helm-values/livekit-egress-values.yaml")]
#   set {
#     name  = "serviceAccount.name"
#     value = "livekit-egress"
#   }
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
#   set {
#       name  = "s3.bucket"
#       value = aws_s3_bucket.livekit_egress.bucket
#   }
#   depends_on = [helm_release.livekit_server, aws_s3_bucket.livekit_egress, kubernetes_service_account.livekit_egress]
# }
