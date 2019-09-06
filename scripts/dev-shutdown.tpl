#!/bin/bash

/usr/bin/bash -c "if /usr/bin/mountpoint -q /home/knisbet/go; then /usr/bin/run-one /usr/bin/rsync -ah /home/knisbet/go/ /home/knisbet/.go/persistent/  --del; fi"