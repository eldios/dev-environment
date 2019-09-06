#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

# Set some curl options so that temporary failures get retried
# More info: https://ec.haxx.se/usingcurl-timeouts.html
CURL_OPTS="--retry 100 --retry-delay 0 --connect-timeout 10 --max-time 300"

sysctl -w fs.inotify.max_user_watches=100000000

#
# Install / Update packages
#
apt-get -y update && sudo apt upgrade -y
apt-get -y install software-properties-common \
    curl \
    wget \
    dnsutils \
    git \
    zsh \
    htop \
    nfs-common

#
# Mount NFS directory structure off dev VM
#
#mkdir -p /nfs/gravity
#mount -t nfs knisbet-dev:/nfs/share/`hostname` /nfs/gravity

#
# Setup a ramdisk for local state
#
#mkdir -p /ram
#mount -t tmpfs tmpfs /ram
#mkdir -p /ram/upper /ram/work /ram/lower
#mkdir -p /gravity/
#mount -t overlay overlay -o lowerdir=/ram/lower:/nfs/knisbet-dev/share,upperdir=/ram/upper,workdir=/ram/work /gravity

#
# Setup automatic shutdown cron
#
echo "0 22,0,2,4,6,8,10 * * * /sbin/shutdown +115" > /etc/cron.d/autoshutdown


if [ ! -f /install_complete ]; then
    touch /install_complete
fi