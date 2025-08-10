# resource "kubernetes_namespace" "livekit" {
#   metadata {
#     name = "livekit"
#   }
# }

# resource "kubernetes_service_account" "livekit_egress" {
#   metadata {
#     name      = "livekit-egress"
#     namespace = kubernetes_namespace.livekit.id
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.livekit_egress_sa.arn
#     }
#   }
# }

# resource "kubernetes_secret" "livekit_turn_tls" {
#   metadata {
#     name      = var.tls_secret_name
#     namespace = kubernetes_namespace.livekit.id
#   }

#   type = "kubernetes.io/tls"

#   data = {
#     "tls.crt" = base64decode(var.tls_crt_content)
#     "tls.key" =  base64decode(var.tls_key_content)
#   }
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
#   depends_on = [module.eks_blueprints_addons]
# }

