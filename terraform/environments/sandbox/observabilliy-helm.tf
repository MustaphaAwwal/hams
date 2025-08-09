
# resource "helm_release" "loki" {
#   name       = "loki"
#   namespace  = "observability"
#   create_namespace = true
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "loki"

#   values = [templatefile("${path.module}/helm-values/loki-values.yaml", {
#     bucket_name = aws_s3_bucket.loki_logs.bucket
#     region      = var.aws_region
#   })]
#   depends_on = [ module.eks_blueprints_addons,
#   module.loki_irsa, aws_s3_bucket.loki_logs
#    ]
# }

# resource "helm_release" "promtail" {
#   name       = "promtail"
#   namespace  = "observability"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "promtail"

#   values = [file("${path.module}/helm-values/promtail-values.yaml")]
# }

# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   namespace  = "observability"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   version    = "0.72.0"
# }

# resource "helm_release" "thanos" {
#   name       = "thanos"
#   namespace  = "observability"
#   repository = "https://bitnami-labs.github.io/sealed-secrets"
#   chart      = "thanos"
#   version    = "15.1.0"

#   values = [file("${path.module}/thanos-values.yaml")]
# }