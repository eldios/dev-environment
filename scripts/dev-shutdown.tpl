#!/bin/bash

/usr/bin/bash -c "if /usr/bin/mountpoint -q /home/${user}/go; then /usr/bin/run-one /usr/bin/rsync -ah /home/${user}/go/ /home/${user}/.go/persistent/  --del; fi"
