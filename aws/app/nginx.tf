resource "helm_release" "nginx" {
  name        = "nginx"
  namespace   = "nginx-ingress"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"

  set {
    name  = "controller.replicaCount"
    value = 2
    type  = "auto"
  }
  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
  set {
    name  = "defaultBackend.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = data.aws_acm_certificate.primary.arn
    type  = "string"
  }

  values = [
    "${file("${path.module}/charts/nginx/values.yaml")}"
  ]

}
