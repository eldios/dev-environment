resource "google_compute_instance" "kubeadm" {
  count                     = var.kubeadm_node_count
  name                      = "${var.env_name}-kubeadm${count.index + 1}"
  description               = "Kubeadm VM - ${var.env_name}"
  machine_type              = var.kubeadmVmType
  zone                      = var.zone
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["${var.env_name}-kubeadm", "devlele"]

  labels = {
    env   = "test"
    user  = var.user
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size  = 60
      type  = "pd-ssd"
      image = var.kubeadmImage
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script  = data.template_file.kubeadm_startup.rendered
    shutdown-script = data.template_file.kubeadm_shutdown.rendered
    ssh_keys = "${var.user}:${file("${var.ssh_keyfile}")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

data "template_file" "kubeadm_startup" {
  template = file("scripts/kubeadm-startup.tpl")

  vars = {
    user = var.user
  }
}

data "template_file" "kubeadm_shutdown" {
  template = file("scripts/kubeadm-shutdown.tpl")

  vars = {
    user = var.user
  }
}
