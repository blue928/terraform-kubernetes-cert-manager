locals {
  issuer_name = var.suffix == null ? "letsencrypt" : "letsencrypt-${var.suffix}"
}

# Cert-manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  create_namespace = true
  #force_update = true

  set {
    name  = "installCRDs"
    value = true
  }


  #depends_on = [var.module_depends_on]
}

# Cert Issuer using Helm
resource "helm_release" "cert_issuer" {
  name       = "cert-issuer"
  repository = path.module
  chart      = "cert-issuer"
  namespace  = var.cert_manager_namespace

  set {
    name  = "fullnameOverride"
    #value = local.issuer_name
    value = "letsencrypt-prod"
  }

  set {
    name  = "privateKeySecretRef"
    value = local.issuer_name
  }

  set {
    name  = "ingressClass"
    value = var.ingress_class
  }

  set {
    name  = "acmeEmail"
    value = var.cert_manager_email
  }

  set {
    name  = "acmeServer"
    value = var.acme_server
  }

  depends_on = [helm_release.cert_manager]
}
