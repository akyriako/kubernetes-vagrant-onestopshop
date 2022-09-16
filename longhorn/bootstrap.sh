#!/bin/bash

echo ">>> ADD LONGHORN DEPENDENCIES"

sudo modprobe iscsi_tcp
sudo apt-get install open-iscsi -y

sudo apt-get install nfs-common -y
