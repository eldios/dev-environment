variable "project" {
  description = "GCP project"
}

variable "region" {
  description = "Region to create cluster"
  default     = "northamerica-northeast1"
}

variable "zone" {
  description = "Region to create cluster"
  default     = "northamerica-northeast1-b"
}

provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

data "google_compute_image" "dev" {
  family  = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}

//
// Create instance for development
//
resource "google_compute_instance" "dev" {
  name                      = "knisbet-dev"
  description               = "Development VM for kevin"
  machine_type              = "custom-10-30720"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = ["knisbet-dev"]

  labels = {
    env   = "dev"
    kevin = ""
    user  = "kevin"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      size = 250
      type = "pd-standard"

      //image = "${data.google_compute_image.dev.self_link}"
      image = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1904-disco-v20190605"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    startup-script  = "${data.template_file.startup.rendered}"
    shutdown-script = "${data.template_file.shutdown.rendered}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-rw"]
  }
}

data "template_file" "startup" {
  template = "${file("scripts/dev-startup.tpl")}"

  vars {}
}

data "template_file" "shutdown" {
  template = "${file("scripts/dev-shutdown.tpl")}"

  vars {}
}

//
// Firewall settings
//
data "google_compute_network" "network" {
  name = "default"
}

resource "google_compute_firewall" "dev" {
  name    = "knisbet-dev-allow"
  network = "${data.google_compute_network.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
