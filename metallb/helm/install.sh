#!/bin/bash

helm repo add metallb https://metallb.github.io/metallb
helm repo update

rm -f /vagrant/metallb/helm/overrides.yaml
envsubst < /vagrant/metallb/helm/overrides.tpl > /vagrant/metallb/helm/overrides.yaml

helm install metallb metallb/metallb -f /vagrant/metallb/helm/overrides.yaml \
	     --namespace metallb-system --create-namespace \
