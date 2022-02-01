module "tls" {
    source = "./tls"
    tls_cname = "${var.tls_cname}"
    tls_altnames = "${var.tls_altnames}"
    tls_organization = "${var.tls_organization}"
    kubeconfig = "${var.kubeconfig}"
}

module "metallb-helm" {
    source = "./metallb-helm"
    kubeconfig = "${var.kubeconfig}"
}

module "ingress-nginx" {
    source = "./ingress-nginx"
    kubeconfig = "${var.kubeconfig}"
}

module "webapp" {
    source = "./webapp"
    kubeconfig = "${var.kubeconfig}"
    webapp_hostname = "${var.webapp_hostname}"
}