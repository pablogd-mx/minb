#!/bin/bash

# Determine Docker's subnet
# docker container inspect mx4pc-cluster-1-control-plane \
#   --format '{{ .NetworkSettings.Networks.kind.IPAddress }}'


NETWORK=$(docker network inspect -f '{{.IPAM.Config}}' kind | awk '{print $1}' | sed 's|/16||g' | sed 's/[^0-9.]//g')

START_NETWORK=${NETWORK//0.0/255.200}
END_NETWORK=${NETWORK//0.0/255.250}
helm upgrade -i -n metallb --create-namespace metallb bitnami/metallb \
    --version 3.0.12 \
    --set "configInline.address-pools[0].name=default" \
    --set "configInline.address-pools[0].protocol=layer2" \
    --set "configInline.address-pools[0].addresses[0]=${START_NETWORK}-${END_NETWORK}" \
    --set "speaker.secretValue=stronk-key"



# # Create a ConfigMap for MetalLB
# cat <<EOF > metallb-config.yaml
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   namespace: metallb-system
#   name: config
# data:
#   config: |
#     address-pools:
#     - name: default
#       protocol: layer2
#       addresses:
#       - $DOCKER_SUBNET
# EOF