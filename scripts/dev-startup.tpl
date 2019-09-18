#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

# Set some curl options so that temporary failures get retried
# More info: https://ec.haxx.se/usingcurl-timeouts.html
CURL_OPTS="--retry 100 --retry-delay 0 --connect-timeout 10 --max-time 300"

sysctl -w fs.inotify.max_user_watches=100000000

#
# Setup a ramdisk to speed up builds
#
mkdir -p /home/${user}/go /home/${user}/.go/ram /home/${user}/.go/persistent/
# chown -R ${user}: /home/${user}/go /home/${user}/.go/
mount -t tmpfs -o size=20g tmpfs /home/${user}/.go/ram
mkdir -p /home/${user}/.go/ram/upper /home/${user}/.go/ram/work
mount -t overlay overlay -o lowerdir=/home/${user}/.go/persistent,upperdir=/home/${user}/.go/ram/upper,workdir=/home/${user}/.go/ram/work /home/${user}/go
chown ${user}: /home/${user}/go 


#
# Setup overlay mounts for test systems
#
for i in {1..5}
do
   mkdir -p /nfs/share/common /nfs/share/${user}-test$${i}
   mkdir -p /nfs/share/.work/${user}-test$${i} /nfs/share/.upper/${user}-test$${i}
   mount -t overlay overlay -o \
    lowerdir=/nfs/share/common,upperdir=/nfs/share/.upper/${user}-test$${i},workdir=/nfs/share/.work/${user}-test$${i} \
    -o nfs_export=on -o index=on \
    /nfs/share/${user}-test$${i}
done

#
# Install packages
#
apt-get -y update && sudo apt upgrade -y
apt-get -y install software-properties-common \
    curl \
    wget \
    dnsutils \
    git \
    zsh \
    htop \
    docker.io \
    nfs-common \
    gcc \
    make \
    tmux \
    screen \
    libudev-dev \
    nfs-kernel-server

if [ ! -f /install_complete ]; then
    #
    # Install golang
    #
    pushd /tmp
    GO_VERSION=1.12.5
    wget https://dl.google.com/go/go$${GO_VERSION}.linux-amd64.tar.gz
    tar -C /usr/local -xzf go$${GO_VERSION}.linux-amd64.tar.gz
    popd

    #
    # Setup automatic shutdown cron
    #
    echo "0 22,0,2,4,6,8,10 * * * /sbin/shutdown +115" > /etc/cron.d/autoshutdown
    echo '*/10 * * * * root /usr/bin/bash -c "if /usr/bin/mountpoint -q /home/${user}/go; then /usr/bin/run-one /usr/bin/rsync -ah /home/${user}/go/ /home/${user}/.go/persistent/  --del; fi"' > /etc/cron.d/sync-ramdrive

    #
    # Allow ${user} to run docker
    #
    usermod -a -G docker ${user}

    touch /install_complete
fi
