variable "kubeconfig" {}
variable "metallb_addresses" {}

variable "use_nginx" {}
variable "use_traefik" {}

variable "ca_cname" {}
variable "ca_organization" {}
variable "ca_validity_period_hours" {}
variable "tls_cname" {}
variable "tls_altnames" {}
variable "tls_organization" {}
variable "tls_validity_period_hours" {}

variable "webapp_hostname" {}
variable "webapp_image" {}
variable "webapp_port" {}
variable "webapp_replicas" {}
variable "webapp_namespace" {}
