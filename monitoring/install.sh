#!/bin/bash

echo ">>> INSTALL METRICS-SERVER"

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server --namespace kube-system 


echo ">>> INSTALL PROMETHEUS"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus --namespace prometheus --create-namespace --set server.persistentVolume.storageClass=longhorn --set alertmanager.persistentVolume.storageClass=longhorn 


echo ">>> INSTALL GRAFANA"

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install grafana grafana/grafana --namespace grafana --create-namespace

