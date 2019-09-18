output "DEV-VMs-IPs" {
    value = "${join("\n",google_compute_instance.dev.*.network_interface.0.access_config.0.nat_ip)}"
}
output "kubeadm-VMs-IPs" {
    value = "${join("\n",google_compute_instance.kubeadm.*.network_interface.0.access_config.0.nat_ip)}"
}
output "test-VMs-IPs" {
    value = "${join("\n",google_compute_instance.test.*.network_interface.0.access_config.0.nat_ip)}"
}
