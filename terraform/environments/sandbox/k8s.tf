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

resource "kubernetes_secret" "tls" {
  metadata {
    name      = var.tls_secret_name
    namespace = kubernetes_namespace.livekit.id
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.tls_crt_content
    "tls.key" =  var.tls_key_content
  }
}

resource "helm_release" "app" {
  depends_on = [kubernetes_secret.tls]
  name       = "my-app"
  chart      = "./charts/my-app"
  namespace  = "my-namespace"
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

