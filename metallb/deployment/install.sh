#!/bin/bash

echo ">>> INSTALL METALLB"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

echo ">>> WAITING METALLB PODS TO GET READY (2m0)"
sleep 120

envsubst < /vagrant/metallb/deployment/ipaddresspool.yaml | kubectl apply -f -


