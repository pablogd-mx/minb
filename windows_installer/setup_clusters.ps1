function Install-Prerequisites {
    Write-Host "Installing prerequisites..."
    # Install KinD
    & go install sigs.k8s.io/kind@v0.11.1

    # Install Helm
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 -OutFile get_helm.ps1
    & ./get_helm.ps1


   # Check if Docker is installed
   Write-Host " Check if docker is installed"
    if (-not (Test-Path (Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"))) {
        Write-Host "Docker is not installed. Installing..."
    
        # Download and install Docker Desktop (assuming Windows)
        Invoke-WebRequest -Uri https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile DockerDesktopInstaller.exe
        Start-Process -Wait -FilePath .\DockerDesktopInstaller.exe
        Remove-Item .\DockerDesktopInstaller.exe
    }
    
    # Check if Docker is running
    if ((docker info) -eq $null) {
        Write-Host "Docker is not running. Starting..."
        Start-Process -NoNewWindow -Wait -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe"  # Adjust path if needed
    } else {
        Write-Host "Docker is already running."
    }

    Write-Host "Prerequisites installed!"
}

function Create-Clusters {
    $numClusters = Read-Host "Enter the number of clusters to create"
    1..$numClusters | ForEach-Object {
        & kind create cluster --name "kind-cluster-$_"
    }
}

function Install-NginxIngress {
    Write-Host "Installing Nginx Ingress Controller..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm install nginx-ingress ingress-nginx/ingress-nginx
}

function Deploy-DockerRegistry {
    Write-Host "Deploying Docker registry with TLS..."
    # Deploy Docker registry with TLS here
}

function Main-Menu {
    Clear-Host
    Write-Host "Welcome to the Cluster Setup Script!"
    Write-Host "Select an option:"
    Write-Host "1. Install prerequisites"
    Write-Host "2. Create KinD clusters"
    Write-Host "3. Install Nginx Ingress Controller"
    Write-Host "4. Deploy Docker registry with TLS"
    Write-Host "5. Exit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 { Install-Prerequisites }
        2 { Create-Clusters }
        3 { Install-NginxIngress }
        4 { Deploy-DockerRegistry }
        5 { Write-Host "Exiting..." ; exit }
        default { Write-Host "Invalid choice. Please select a valid option." }
    }

    $continueChoice = Read-Host "Do you want to return to the main menu? (Y/N)"
    if ($continueChoice -eq "Y" -or $continueChoice -eq "y") {
        Main-Menu
    }
}

# Start the script
Main-Menu
