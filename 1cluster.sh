#!/bin/bash

# Function to install kind and set up the cluster
    echo "Installing kind..."
    GO111MODULE="on" go install sigs.k8s.io/kind@v0.11.1

    echo "Creating KinD cluster..."
    kind create cluster --name mykindcluster

# Function to install and configure local Docker registry with HTTPS
    echo "Installing local Docker registry..."
    docker run -d -p 5002:5002 --restart=always --name registry registry:2

    echo "Generating self-signed certificate for the registry..."
    mkdir -p certs
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 \
        -subj "/C=US/ST=CA/L=City/O=Organization/OU=Unit/CN=registry.localhost" \
        -out certs/domain.crt

    echo "Setting up the registry configuration..."
    cat > registry-config.yml <<EOF
version: 0.1
log:
  level: debug
storage:
  filesystem: {}
http:
  addr: :5002
  secret: secret
  tls:
    certificate: /certs/domain.crt
    key: /certs/domain.key
EOF
    mv certs domain.crt domain.key registry-config.yml /var/lib/registry/

    echo "Running the registry container with TLS..."
    docker stop registry
    docker rm registry
    docker run -d -p 5002:5002 --restart=always --name registry \
        -v /var/lib/registry:/var/lib/registry \
        -v /var/lib/registry/certs/domain.crt:/certs/domain.crt \
        -v /var/lib/registry/certs/domain.key:/certs/domain.key \
        -v /var/lib/registry/registry-config.yml:/etc/docker/registry/config.yml \
        registry:2

# Function to configure KinD cluster to use the local registry
    echo "Configuring KinD to use local registry..."
    export KUBECONFIG="$(kind get kubeconfig-path --name=mykindcluster)"
    kubectl apply -f registry-config.yml

