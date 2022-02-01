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