
# resource "helm_release" "loki" {
#   name       = "loki"
#   namespace  = "observability"
#   create_namespace = true
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "loki-simple-scalable"

#   values = [file("${path.module}/helm-values/loki-values.yaml")]
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
#   depends_on = [ helm_release.loki ]
# }

# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   namespace  = "observability"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   version    = "0.72.0"
# }
