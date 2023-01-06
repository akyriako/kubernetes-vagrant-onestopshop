#!/bin/bash

echo ">>> INSTALL LONGHORN"

helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace

echo ">>> WAITING LONGHORN PODS TO GET READY (5m0)"
sleep 300
