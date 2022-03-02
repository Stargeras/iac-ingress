variable "metallb_addresses" {
  type    = string
  default = "23.82.1.70/32"
}

variable "use_nginx" {
  type    = bool
  default = true
}

variable "use_traefik" {
  type    = bool
  default = false
}

variable "tls_cname" {
  type    = string
  default = "local.domain"
}

variable "tls_altnames" {
  type = list(any)
  default = [
    "*.local.domain"
  ]
}

variable "tls_organization" {
  type    = string
  default = "Kubernetes, Inc"
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}

variable "webapp_hostname" {
  type    = string
  default = "webapp.local.domain"
}

variable "webapp_image" {
  type    = string
  default = "nginx"
}

variable "webapp_port" {
  type    = number
  default = 80
}

variable "webapp_replicas" {
  type    = number
  default = 3
}

variable "webapp_namespace" {
  type    = string
  default = "default"
}
