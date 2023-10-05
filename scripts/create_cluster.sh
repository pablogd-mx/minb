#!/bin/bash
read -p "Enter the number of clusters to create: " num_clusters
        
    if ! docker info &> /dev/null; then
        echo "Docker is not running. Starting..."
        open --background -a Docker  # Start Docker on macOS
    
    # Wait for Docker to start
     while ! docker info &> /dev/null; do
            sleep 1
     done
fi
  
for ((i=1; i<=$num_clusters; i++)); do
    cluster_name="mx4pc-cluster-$i"
    namespace_name="pmp-ns-$i"
    echo "Creating cluster: $cluster_name"
    kind create cluster --name "$cluster_name" --config=config/cluster_config.yaml
    
    echo "Cluster $i created successfully!"
 done