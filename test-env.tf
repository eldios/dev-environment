variable "node_count" {
  default = "0"
}

//
// Separate disk for etcd
//
resource "google_compute_disk" "test-etcd-disk-" {
  count = "${var.node_count}"
  name  = "knisbet-test-disk-${count.index}-etcd"
  type  = "pd-ssd"
  size  = "50"

  labels = {
    env   = "test"
    kevin = ""
    user  = "kevin"
  }
}

//
// Create instance for testing gravity
//
resource "google_compute_instance" "test" {
  count                     = "${var.node_count}"
  name                      = "knisbet-test${count.index + 1}"
  description               = "Test VM for kevin"
  machine_type              = "custom-6-10240"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["knisbet-dev"]

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
      image = "${data.google_compute_image.dev.self_link}"
    }
  }

  attached_disk {
    source      = "${element(google_compute_disk.test-etcd-disk-.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.test-etcd-disk-.*.name, count.index)}"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    startup-script  = "${data.template_file.test_startup.rendered}"
    shutdown-script = "${data.template_file.test_shutdown.rendered}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

data "template_file" "test_startup" {
  template = "${file("scripts/test-startup.tpl")}"

  vars {}
}

data "template_file" "test_shutdown" {
  template = "${file("scripts/test-shutdown.tpl")}"

  vars {}
}
