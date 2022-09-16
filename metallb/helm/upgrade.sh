#!/bin/bash

helm upgrade metallb metallb/metallb -f overrides.yaml \
	     --namespace metallb-system 
