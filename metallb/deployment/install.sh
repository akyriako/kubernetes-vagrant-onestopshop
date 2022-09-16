#!/bin/bash

echo ">>> INSTALL METALLB"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

envsubst < /vagrant/metallb/deployment/config-map.yaml | kubectl apply -f -


