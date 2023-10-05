#!/bin/bash

read -p "Enter the version of MxOperator to install:" mxversion
echo "Installing PostgresSQL"
        helm repo add bitnami https://charts.bitnami.com/bitnami
        kubectl create namespace pmp-storage
        helm install postgres-shared bitnami/postgresql --namespace=pmp-storage --set auth.postgresPassword=Password1\! --set persistence.size=1Gi
    
    # Install Minio using Helm  
    echo "Installing Minio Storage"
        helm install minio-shared bitnami/minio --namespace=pmp-storage --set auth.rootUser=minioadmin --set auth.rootPassword=Password1\! --set persistence.size=1Gi   
    
    # echo "Installing Ngnix"
    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/kind/deploy.yaml


    echo "Installing and configuring MetalLB"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
    #./config/metallb-config.sh
    kubectl apply -f ./config/metallb-config.yaml

    # Install Mx4PC Operator ( Connected)
     echo "Installing Mx4PC Operator (Connected)"
     wget -c https://cdn.mendix.com/mendix-for-private-cloud/mxpc-cli/mxpc-cli-$mxversion.0-macos-amd64.tar.gz 
     tar -zxvf mxpc-cli*
     chmod +x *mxpc-cli
     sleep 2
     #./mxpc-cli base-install -n $namespace_name -t generic -m con
     ./mxpc-cli base-install -n $namespace_name -t generic -i 1e7990dd-806d-45b8-b4f8-36da10415d2b -s 19SGZQOQZsz02Csd -m connected
     sleep 3
    # Configure Mx4PC Operator
    #  ./mxpc-cli apply-config -f mx_config_cli_2.yaml 
    rm -rf mxpc-cli*
    echo " *********************"

    # Configure Registry
    ./config/configure_registry.sh
    sleep 5

    echo " Database endpoint is: postgres-shared-postgresql.pmp-storage.svc.cluster.local:5432. Check secrets for credentials"
    echo " Storage endpoint is: http://minio-shared.pmp-storage.svc.cluster.local:9000. Check secrets for credentials"
    echo " Registry from the nodes is localhost:5001, from the Pods kind-registry.local:5001"
    echo " *********************"