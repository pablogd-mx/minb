function Install-Prerequisites {
    if (-Not (Test-Path -Path "C:\Program Files\Docker\Docker\Docker Desktop.exe" -PathType Leaf)) {
        Write-Host "Installing Docker for Windows..."

        if (-Not (Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
            Write-Host "Chocolatey not found. Installing Chocolatey..."
            Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }

        choco install docker-desktop -y
    }
    else {
        Write-Host "Docker already installed, skipping"
    }

   
    if (-Not (Get-Command -Name 'kind' -ErrorAction SilentlyContinue)) {
   
        Write-Host "Installing KinD..."
        choco install kind

    }
    else {
        Write-Host "KinD already installed, skipping"
    }

   
    if (-Not (Get-Command -Name 'helm' -ErrorAction SilentlyContinue)) {
   
        Write-Host "Installing Helm..."
        choco install kubernetes-helm

    }
    else {
        Write-Host "Helm already installed, skipping"
    }

    Write-Host "Prerequisites installed!"
}



function Create-Clusters {
    $numClusters = Read-Host "Enter the number of clusters to create"

    for ($i = 1; $i -le $numClusters; $i++) {
        $clusterName = "mx4pc-cluster-$i"
        $namespaceName = "pmp-ns"
        $HTTP_PORT = 8000 + $i
        $HTTPS_PORT = 8443 + $i

        Write-Host "Creating cluster: $clusterName"

        # Create a KiND cluster using the config file with extra port mappings
        $kindConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
nodes:
- role: control-plane
  image: kindest/node:v1.23.17@sha256:59c989ff8a517a93127d4a536e7014d28e235fb3529d9fba91b3951d461edfdb
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: $HTTP_PORT
    protocol: TCP
  - containerPort: 443
    hostPort: $HTTPS_PORT
    protocol: TCP
- role: worker
  image: kindest/node:v1.23.17@sha256:59c989ff8a517a93127d4a536e7014d28e235fb3529d9fba91b3951d461edfdb
"@

        $kindConfig | Out-File -FilePath "kind-config.yaml" -Encoding UTF8
        kind create cluster --name "cluster$i" --config=kind-config.yaml
        Remove-Item -Path "kind-config.yaml"
        Write-Host "Cluster $i created successfully!"
    }
}

# Other functions: install_mx4pc_standalone, deploy_test_app, delete_all_kind_clusters

function Main-Menu {
    Clear-Host
    Write-Host "Welcome to the Cluster Setup Script!"
    Write-Host "Select an option:"
    Write-Host "1. Install prerequisites"
    Write-Host "2. Create KinD clusters"
    Write-Host "3. Install & Configure Mx4PC Standalone"
    Write-Host "4. Deploy Test App"
    Write-Host "5. Delete all clusters"
    Write-Host "6. Exit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 { Install-Prerequisites }
        2 { Create-Clusters }
        3 { Install-Mx4pc-Standalone }
        4 { Deploy-Test-App }
        5 { Delete-All-Kind-Clusters }
        6 { Write-Host "Exiting..."; return }
        default { Write-Host "Invalid choice. Please select a valid option." }
    }

    $continueChoice = Read-Host "Do you want to return to the main menu? (Y/N)"
    if ($continueChoice -eq "Y" -or $continueChoice -eq "y") {
        Main-Menu
    }
}

# Start the script
Main-Menu
