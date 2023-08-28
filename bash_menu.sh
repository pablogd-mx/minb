#!/bin/bash

# Function to install prerequisites
install_prerequisites() {
    echo "Installing prerequisites..."
    # Install KinD
    #GO111MODULE="on" go get sigs.k8s.io/kind@v0.11.1
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-darwin-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/
    # Install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh

    echo "Prerequisites installed!"
}

# Function to create KinD clusters
create_clusters() {
    read -p "Enter the number of clusters to create: " num_clusters
    read -p "Enter the version of MxOperator to install: " mxversion
    #Checking if Docker is running
    echo "Checking if Docker daemon is running, or else..."
    open /Applications/Docker.app
    sleep 15

for ((i=1; i<=$num_clusters; i++)); do
    cluster_name="mx4pc-cluster-$i"
    namespace_name="pmp-ns-$i"
    echo "Creating cluster: $cluster_name"
    kind create cluster --name "$cluster_name"
    
    # Install Docker registry using Helm - TODO
    # kubectl create namespace docker-registry
    # helm repo add stable https://charts.helm.sh/stable
    # helm install registry stable/docker-registry --namespace docker-registry
    # Install PostgreSQL using Helm
    echo "Installing PostgresSQL"
        helm repo add bitnami https://charts.bitnami.com/bitnami
        kubectl create namespace pmp-storage
        helm install postgres-shared bitnami/postgresql --namespace=pmp-storage --set auth.postgresPassword=Password1\! --set image.tag=12 --set persistence.size=1Gi
    
    # Install Minio using Helm  
    echo "Installing Minio Storage"
        helm install minio-shared bitnami/minio --namespace=pmp-storage --set auth.rootUser=minioadmin --set auth.rootPassword=Password1\! --set persistence.size=5Gi   
    echo "Cluster $i created and components installed successfully!"

    # Install Mx4PC Operator ( Standalone)
     echo "Installing Mx4PC Operator (Standalone)"
     wget -c https://cdn.mendix.com/mendix-for-private-cloud/mxpc-cli/mxpc-cli-$mxversion.0-macos-amd64.tar.gz 
     tar -zxvf mxpc-cli*
     chmod +x *mxpc-cli
     ./mxpc-cli base-install -n $namespace_name -t generic -m standalone

    echo " *********************"

    echo " Database endpoint is: postgres-shared-postgresql.pmp-storage.svc.cluster.local:5432. Check secrets for credentials"
    echo " Storage endpoint is: http://minio-shared.pmp-storage.svc.cluster.local:9000. Check secrets for credentials"
 
    echo " *********************"

 done

}

# install_mx4pc_standalone() {

# }

install_mx4pc_connected() {
    echo " Yet to be done"

}

delete_all_kind_clusters() {
    echo "Deleting all KinD clusters..."
    kind get clusters | while read -r cluster; do
        kind delete cluster --name "$cluster"
    done
    echo "All KinD clusters deleted."
}


# Main menu
main_menu() {
    clear
    echo "Welcome to the Cluster Setup Script!"
    echo "Select an option:"
    echo "1. Install prerequisites"
    echo "2. Create KinD clusters"
    echo "3. Install & Configure Mx4PC Standalone"
    echo "4. Install & Configure Mx4PC Connected"
    echo "5. Delete all clusters"
  #  echo "4. Deploy Harbor registry with TLS"
    echo "6. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_prerequisites
            ;;
        2)
            create_clusters
            ;;
        3)
            install_mx4pc_standalone
            ;;
        4)
            install_mx4pc_connected
            ;;
        5) 
            delete_all_kind_clusters
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac

    read -p "Do you want to return to the main menu? (Y/N): " continue_choice
    if [ "$continue_choice" == "Y" ] || [ "$continue_choice" == "y" ]; then
        main_menu
    fi
}

# Start the script
main_menu