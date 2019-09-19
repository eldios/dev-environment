resource "google_compute_instance" "dev" {
  count                     = "${var.dev_node_count}"
  name                      = "${var.env_name}-dev-${count.index}"
  description               = "Development VM - ${var.env_name}"
  machine_type              = "custom-10-30720"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["${var.env_name}"]

  labels = {
    env   = "dev"
    user  = "${var.user}"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size = 250
      type = "pd-standard"

      image = "${var.devImage}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }

  }

  metadata = {
    startup-script  = "${data.template_file.startup.rendered}"
    shutdown-script = "${data.template_file.shutdown.rendered}"
    ssh_keys        = "${var.user}:${file("${var.ssh_keyfile}")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

data "google_compute_network" "network" {
  name = "default"
}

resource "google_compute_firewall" "dev" {
  name    = "${var.env_name}-allow"
  network = "${data.google_compute_network.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "template_file" "startup" {
  template = "${file("scripts/dev-startup.tpl")}"

  vars = {
    user = "${var.user}"
  }
}

data "template_file" "shutdown" {
  template = "${file("scripts/dev-shutdown.tpl")}"

  vars = {
    user = "${var.user}"
  }
}
