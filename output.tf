output "shared_ssh_config"{
  value = <<-SSHCONFIG

Host ${var.env_name}.* 
  User ${var.user}
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  ForwardAgent yes 
  IdentitiesOnly yes 
  LogLevel FATAL
  IdentityFile ${var.ssh_keyfile}
SSHCONFIG
}

output "dev_ssh_config"{
    value = <<-SSHCONFIG
%{ for host in google_compute_instance.dev.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
SSHCONFIG
}

output "kubeadmVM_ssh_config"{
    value = <<-SSHCONFIG
%{ for host in google_compute_instance.kubeadm.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
SSHCONFIG
}

output "test_ssh_config"{
    value = <<-SSHCONFIG
%{ for host in google_compute_instance.test.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
SSHCONFIG
}
