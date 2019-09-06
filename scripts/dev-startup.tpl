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
mkdir -p /home/knisbet/go /home/knisbet/.go/ram /home/knisbet/.go/persistent/
# chown -R knisbet /home/knisbet/go /home/knisbet/.go/
mount -t tmpfs -o size=20g tmpfs /home/knisbet/.go/ram
mkdir -p /home/knisbet/.go/ram/upper /home/knisbet/.go/ram/work
mount -t overlay overlay -o lowerdir=/home/knisbet/.go/persistent,upperdir=/home/knisbet/.go/ram/upper,workdir=/home/knisbet/.go/ram/work /home/knisbet/go
chown knisbet:knisbet /home/knisbet/go 


#
# Setup overlay mounts for test systems
#
for i in {1..5}
do
   mkdir -p /nfs/share/common /nfs/share/knisbet-test$${i}
   mkdir -p /nfs/share/.work/knisbet-test$${i} /nfs/share/.upper/knisbet-test$${i}
   mount -t overlay overlay -o \
    lowerdir=/nfs/share/common,upperdir=/nfs/share/.upper/knisbet-test$${i},workdir=/nfs/share/.work/knisbet-test$${i} \
    -o nfs_export=on -o index=on \
    /nfs/share/knisbet-test$${i}
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
    echo '*/10 * * * * root /usr/bin/bash -c "if /usr/bin/mountpoint -q /home/knisbet/go; then /usr/bin/run-one /usr/bin/rsync -ah /home/knisbet/go/ /home/knisbet/.go/persistent/  --del; fi"' > /etc/cron.d/sync-ramdrive

    #
    # Allow knisbet to run docker
    #
    usermod -a -G docker knisbet

    touch /install_complete
fi