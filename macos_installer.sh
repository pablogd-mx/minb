#!/bin/bash

# Function to install prerequisites
install_prerequisites() {

    # Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker for macOS..."

    # Check if Homebrew is installed, and install it if not
        if ! command -v brew &> /dev/null; then
             echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            echo "Brew installed succesfully..."
        fi
    
    # Install Docker using Homebrew
    brew install docker
else 
echo "Docker already installed, skipping"
fi

# Install KinD
    #GO111MODULE="on" go get sigs.k8s.io/kind@v0.11.1
echo " Check if Kind is installed"
if ! command -v kind &> /dev/null; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-darwin-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/
    else
       echo "Kind already installed, skipping"
fi
    # Install Helm
if ! command -v helm &> /dev/null; then
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod +x get_helm.sh
        ./get_helm.sh
        rm -rf get_helm*
else
        echo "Helm already installed, skipping"
fi
    echo "Prerequisites installed!"
}

# Function to create KinD clusters
create_clusters() {
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
}
install_mx4pc_standalone() {

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
    # kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
    # #./config/metallb-config.sh
    # kubectl apply -f ./config/metallb-config.yaml
    ./config/metallb-config.sh

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
     #./mxpc-cli apply-config -f mx_config_cli_2.yaml 
    rm -rf mxpc-cli*
    echo " *********************"

    # Configure Registry
    ./config/configure_registry.sh
    sleep 5

    echo " Database endpoint is: postgres-shared-postgresql.pmp-storage.svc.cluster.local:5432. Check secrets for credentials"
    echo " Storage endpoint is: http://minio-shared.pmp-storage.svc.cluster.local:9000. Check secrets for credentials"
    echo " Registry from the nodes is localhost:5001, from the Pods kind-registry.local:5001"
    echo " *********************"

}

deploy_test_app() {
   sleep 10 # Wait for Minio and Postgres to be ready
   kubectl apply -n $namespace_name -f config/app_cr.yaml 
}

delete_all_kind_clusters() {
echo "Deleting all KinD clusters..."
    kind get clusters | while read -r cluster; do
    kind delete cluster --name "$cluster"
    done
    
    #Deleting Container Registry
    docker container stop kind-registry.local
    docker container rm kind-registry.local
    
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
    echo "4. Deploy Test App"
    echo "5. Delete all clusters"
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
            deploy_test_app
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