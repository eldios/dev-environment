resource "google_compute_instance" "hub" {
  count                     = var.hub_node_count
  name                      = "${var.env_name}-hub${count.index}"
  description               = "Hub VM - ${var.env_name}"
  machine_type              = var.hubVmType
  zone                      = var.zone
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["${var.env_name}-hub", "hub-lele"]

  labels = {
    env   = "test"
    user  = var.user
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size  = 60
      type  = "pd-ssd"
      image = var.hubImage
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script  = data.template_file.hub_startup.rendered
    shutdown-script = data.template_file.hub_shutdown.rendered
    ssh_keys = "${var.user}:${file("${var.ssh_keyfile}")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

resource "google_compute_firewall" "hub-fw" {
  count   = 1
  name    = "${var.env_name}-hub-allow"
  network = data.google_compute_network.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["hub-lele"]
}

data "template_file" "hub_startup" {
  template = file("scripts/hub-startup.tpl")

  vars = {
    user = var.user
  }
}

data "template_file" "hub_shutdown" {
  template = file("scripts/hub-shutdown.tpl")

  vars = {
    user = var.user
  }
}
