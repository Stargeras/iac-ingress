variable "tls_cname" {
    type = string
    default = "svc.cluster.local"
}

variable "tls_altnames" {
    type = list
    default = [
        "*.svc.cluster.local"
    ]
}

variable "tls_organization" {
    type = string
    default = "Kubernetes, Inc"
}

variable "kubeconfig" {
    type = string
    default = "~/.kube/config"
}

variable "webapp_hostname" {
    type = string
    default = "webapp.svc.cluster.local"
}

variable "webapp_image" {
    type = string
    default = "nginx"
}

variable "webapp_port" {
    type = number
    default = 80
}

variable "webapp_replicas" {
    type = number
    default = 3
}

variable "use_nginx" {
    type = bool
    default = true
}

variable "use_traefik" {
    type = bool
    default = false
}
