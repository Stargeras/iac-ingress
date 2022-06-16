module "metallb" {
  source            = "./module-metallb"
  kubeconfig        = var.kubeconfig
  metallb_addresses = var.metallb_addresses
}

module "traefik" {
  source      = "./module-traefik"
  kubeconfig  = var.kubeconfig
  use_traefik = var.use_traefik
}

module "tls" {
  source                    = "./module-tls"
  ca_cname                  = var.ca_cname
  ca_organization           = var.ca_organization
  ca_validity_period_hours  = var.ca_validity_period_hours
  tls_cname                 = var.tls_cname
  tls_altnames              = var.tls_altnames
  tls_organization          = var.tls_organization
  tls_validity_period_hours = var.tls_validity_period_hours
  kubeconfig                = var.kubeconfig
}

module "nginx-ingress" {
  source     = "./module-nginx-ingress"
  kubeconfig = var.kubeconfig
  use_nginx  = var.use_nginx
}

module "webapp" {
  source           = "./module-webapp"
  kubeconfig       = var.kubeconfig
  webapp_hostname  = var.webapp_hostname
  webapp_image     = var.webapp_image
  webapp_port      = var.webapp_port
  webapp_replicas  = var.webapp_replicas
  webapp_namespace = var.webapp_namespace
  use_nginx        = var.use_nginx
  use_traefik      = var.use_traefik
}
