#!/bin/bash

read -p "Enter the number of clusters needed: " num_clusters

for ((i=1; i<=$num_clusters; i++)); do
    cluster_name="mx4pc-cluster-$i"
    
    echo "Creating cluster: $cluster_name"
    
    kind create cluster --name "$cluster_name"
    
    # Install Docker registry using Helm
    kubectl create namespace docker-registry
    helm repo add stable https://charts.helm.sh/stable
    helm install registry stable/docker-registry --namespace docker-registry
    
    # Install PostgreSQL using Helm
    helm repo add bitnami https://charts.bitnami.com/bitnami
    kubectl create namespace privatecloud-storage
    helm install postgres-shared bitnami/postgresql --namespace=privatecloud-storage --set auth.postgresPassword=Password1\! --set image.tag=12 --set persistence.size=1Gi
    
    # Install Minio using Helm
    helm install minio-shared bitnami/minio --namespace=privatecloud-storage --set auth.rootUser=minioadmin --set auth.rootPassword=Password1\! --set persistence.size=5Gi   
    echo "Cluster $i created and components installed successfully!"
done

