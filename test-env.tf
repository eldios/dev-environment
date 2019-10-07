resource "google_compute_disk" "test-gravity-disk-" {
  count = "${var.test_node_count}"
  name  = "${var.env_name}-test-disk-${count.index}-gravity"
  type  = "pd-ssd"
  size  = "100"

  labels = {
    env   = "test"
    user  = "${var.user}"
  }
}

resource "google_compute_disk" "test-etcd-disk-" {
  count = "${var.test_node_count}"
  name  = "${var.env_name}-test-disk-${count.index}-etcd"
  type  = "pd-ssd"
  size  = "50"

  labels = {
    env   = "test"
    user  = "${var.user}"
  }
}

resource "google_compute_instance" "test" {
  count                     = "${var.test_node_count}"
  name                      = "${var.env_name}-test${count.index + 1}"
  description               = "Test VM - ${var.env_name}"
  machine_type              = "${var.testVmType}"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["${var.env_name}-dev", "devlele"]

  labels = {
    env   = "test"
    user  = "${var.user}"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size  = 60
      type  = "pd-ssd"
      image = "${var.testImage}"
    }
  }

  attached_disk {
    source      = "${element(google_compute_disk.test-etcd-disk-.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.test-etcd-disk-.*.name, count.index)}"
  }

  attached_disk {
    source      = "${element(google_compute_disk.test-gravity-disk-.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.test-gravity-disk-.*.name, count.index)}"
  }

  metadata = {
    startup-script  = "${data.template_file.test_startup.rendered}"
    shutdown-script = "${data.template_file.test_shutdown.rendered}"
    ssh_keys = "${var.user}:${file("${var.ssh_keyfile}")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }

  }
}

data "template_file" "test_startup" {
  template = "${file("scripts/test-startup.tpl")}"

  vars = {
    user = "${var.user}"
  }
}

data "template_file" "test_shutdown" {
  template = "${file("scripts/test-shutdown.tpl")}"

  vars = {
    user = "${var.user}"
  }
}
