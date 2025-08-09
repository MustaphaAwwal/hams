resource "kubernetes_namespace" "livekit" {
  metadata {
    name = "livekit"
  }
}

resource "kubernetes_service_account" "livekit_egress" {
  metadata {
    name      = "livekit-egress"
    # namespace = kubernetes_namespace.livekit.id
    namespace = "livekit"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.livekit_egress_sa.arn
    }
  }
}

# resource "kubernetes_secret" "thanos_objstore" {
#   metadata {
#     name      = "thanos-objstore"
#     namespace = "kube-prometheus-stack"
#   }

#   data = {
#     "objstore.yaml" = filebase64("${path.module}/thanos_s3_config.yaml")
#   }

#   type = "Opaque"
# }



# resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind" = "ClusterIssuer"
#     "metadata" = {
#       "name" = "letsencrypt-prod"
#     }
#     "spec" = {
#       "acme" = {
#         "email" = "awwalmustapha41@gmail.com"
#         "server" = "https://acme-v02.api.letsencrypt.org/directory"
#         "privateKeySecretRef" = {
#           "name" = "letsencrypt-prod"
#         }
#         "solvers" = [
#           {
#             "http01" = {
#               "ingress" = {
#                 "class" = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
#   depends_on = [module.eks]
# }

