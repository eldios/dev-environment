################################################################################
######################### CLUSTER SETTINGS #####################################
################################################################################

variable env_name {
  description = "Name assigned to Environment resources"
  default = "test-env"
}
variable user {
  description = "Username used to SSH on vms"
}
variable ssh_keyfile {
  description = "Public SSH keyfile used for SSH connections"
  default = "~/.ssh/id_rsa.pub"
}

variable "project" {
  description = "GCP project"
  default = "your-google-project"
}
variable "region" {
  description = "Region to create cluster"
  default     = "europe-west3"
}
variable "zone" {
  description = "Region to create cluster"
  default     = "europe-west3-c"
}

################################################################################
############################### DEV VM #########################################
################################################################################

variable dev_node_count {
  description = "Number of dev nodes to be used a new cluster"
  default = 0
}
variable "devImage" {
  description = "OS Image used by DEV VM"
  default = "ubuntu-1904-disco-v20190903"
}
variable "devVmType" {
  description = "Instance type used for DEV VMs"
  default = "f1-micro"
}

################################################################################
############################### KUBEADM VM #####################################
################################################################################

variable kubeadm_node_count {
  description = "Enable (1) or disable (0) creation of kubeadm VM"
  default = 0
}
variable "kubeadmImage" {
  description = "OS Image used by kubeadm VM"
  default = "ubuntu-1904-disco-v20190903"
}
variable "kubeadmVmType" {
  description = "Instance type used for DEV VMs"
  default = "n1-standard-1"
}

################################################################################
############################## TEST VM #########################################
################################################################################

variable test_node_count {
  description = "Number of test nodes to be used a new cluster"
  default = 0
}
variable "testImage" {
  description = "OS Image used by test VMs"
  default = "ubuntu-1904-disco-v20190903"
}
variable "testVmType" {
  description = "Instance type used for DEV VMs"
  default = "n1-standard-1"
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
