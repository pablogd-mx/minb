#!/bin/bash

# Function to install k3d and create clusters
install_k3d_and_create_clusters() {
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.6 bash

    echo "Creating clusters..."
    k3d cluster create mycluster
}

# Function to install and configure local Docker registry with HTTPS
install_local_registry() {
    echo "Installing local Docker registry..."
    docker run -d -p 5001:5001 --restart=always --name registry registry:2

    echo "Generating self-signed certificate for the registry..."
    mkdir -p certs
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -subj "/C=US/ST=CA/L=City/O=Organization/OU=Unit/CN=registry.localhost" -out certs/domain.crt
    echo "Setting up the registry configuration for k3d..."
    k3d registry create registry.localhost --port 5001 

    echo "Updating /etc/hosts file..."
    echo "127.0.0.1 registry.localhost" | sudo tee -a /etc/hosts > /dev/null

    echo "Configuring k3d to use the local registry..."
    k3d cluster create mycluster --registry-use k3d-registry.localhost:5001
}

# Main menu
main_menu() {
    clear
    echo "Welcome to the Cluster Setup Script!"
    echo "Select an option:"
    echo "1. Install k3d and create clusters"
    echo "2. Install local Docker registry with HTTPS"
    echo "3. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_k3d_and_create_clusters
            ;;
        2)
            install_local_registry
            ;;
        3)
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
