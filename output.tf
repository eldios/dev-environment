output "ssh_config"{
  value = <<-SSHCONFIG

##################################### SHARED ##################################
Host ${var.env_name}-* 
  User ${var.user}
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  ForwardAgent yes 
  IdentitiesOnly yes 
  LogLevel FATAL
  IdentityFile ${var.ssh_keyfile}
###############################################################################

###################################### DEV ####################################
%{ for host in google_compute_instance.dev.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
###############################################################################

###################################### HUB ####################################
%{ for host in google_compute_instance.hub.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
###############################################################################

###################################### TEST ###################################
%{ for host in google_compute_instance.test.* ~}

Host ${host.name}
    Hostname ${host.network_interface.0.access_config.0.nat_ip}
%{ endfor ~}
###############################################################################
SSHCONFIG
}
