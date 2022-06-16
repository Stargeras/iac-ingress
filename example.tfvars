kubeconfig = "~/.kube/config"
metallb_addresses = "23.82.1.70/32"

use_nginx = true
use_traefik = false

tls_cname = "local.domain"
tls_altnames = [
  "*.local.domain"
]
tls_organization = "Kubernetes, Inc"

webapp_hostname = "webapp.local.domain"
webapp_image = "nginx"
webapp_port = 80
webapp_replicas = 3
webapp_namespace = "default"
