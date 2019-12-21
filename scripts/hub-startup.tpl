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
    nfs-common \
    docker.io

#
# Setup automatic shutdown cron
#
echo "0 22,0,2,4,6,8,10 * * * root /sbin/shutdown +115" > /etc/cron.d/autoshutdown


if [ ! -f /install_complete ]; then
    touch /install_complete

    #
    # Install WireGuard
    #
    add-apt-repository -y ppa:wireguard/wireguard
    apt-get -y install wireguard

    #
    # Install kubernetes packages
    #
    curl $CURL_OPTS -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
    apt-get install -y kubectl
fi
