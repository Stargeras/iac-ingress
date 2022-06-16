kubeconfig = "~/.kube/config"
metallb_addresses = "23.82.1.70/32"

use_nginx = true
use_traefik = false

ca_cname = "Laodicea"
ca_organization = "Laodicea, Inc"
ca_validity_period_hours = 17520

tls_cname = "local.domain"
tls_altnames = [
  "*.local.domain"
]
tls_organization = "Kubernetes, Inc"
tls_validity_period_hours = 17520

webapp_hostname = "webapp.local.domain"
webapp_image = "nginx"
webapp_port = 80
webapp_replicas = 3
webapp_namespace = "default"
