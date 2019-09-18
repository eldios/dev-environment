# Introduction

This repo is used to create multiple VMs for development environments.

!!! Please don't use in production !!!

# Installation

In order to create your new dev environment, you'll use:

* Terraform
* Google-Cloud-SDK (needs to be pre-configured and working)

First of all start by configuring your env via the `gcp.tfvars` file, by setting
all the needed variables correctly.

Then simply run:

```
terraform init
terraform plan -var-file=gcp.tfvars -out myenv.plan
terraform apply myenv.plan
```

If everything runs correctltly, after a few seconds you should be able to run:

```
terraform output
```

and have a text output compatible with your `ssh_config` file, so that if you
add:

```
Include ~/.ssh/*-dev.conf
```

at the top of your `~/.ssh/config` file and then run

```
terraform output | tail +2 > ~/.ssh/myenv-dev.conf
```

Then you'll be able to ssh directly into your new VMs with no further conf.
