variable "kubeadm_node_count" {
  default = "0"
}

data "google_compute_image" "kubeadm" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

//
// Create instance for testing gravity
//
resource "google_compute_instance" "kubeadm" {
  count                     = "${var.kubeadm_node_count}"
  name                      = "knisbet-kubeadm${count.index + 1}"
  description               = "Kubeadm VM for kevin"
  machine_type              = "custom-4-8192"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["knisbet-kubeadm"]

  labels = {
    env   = "test"
    kevin = ""
    user  = "kevin"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size  = 60
      type  = "pd-ssd"
      image = "${data.google_compute_image.kubeadm.self_link}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    startup-script  = "${data.template_file.kubeadm_startup.rendered}"
    shutdown-script = "${data.template_file.kubeadm_shutdown.rendered}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

data "template_file" "kubeadm_startup" {
  template = "${file("scripts/kubeadm-startup.tpl")}"

  vars {}
}

data "template_file" "kubeadm_shutdown" {
  template = "${file("scripts/kubeadm-shutdown.tpl")}"

  vars {}
}
