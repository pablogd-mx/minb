# Docker Registry Setup Script

This script automates the setup of a local Docker container registry using a Helm chart with TLS certificates. It also configures the registry to work with a Kubernetes Kind cluster and Nginx Ingress for HTTPS access.

## Features

- Installs the Nginx Ingress Controller (if not already installed).
- Generates self-signed TLS certificates for the registry.
- Installs the Docker registry via Helm chart with TLS support.
- Configures the registry to work with Kind and Nginx Ingress.

## Supported Operating Systems

- Windows (PowerShell)
- Linux (Bash)
- macOS (Zsh)

## Usage

1. Clone this repository to your local machine.

2. Open a terminal and navigate to the repository directory.

3. Depending on your operating system, follow the appropriate instructions below:

### Windows (PowerShell)

1. Open PowerShell as an administrator.

2. Run the following command to execute the script:

   ```powershell
   .\install_registry.ps1


The script will install the required tools and set up the Docker registry. Follow the on-screen prompts.

## Linux (Bash)
Open a terminal.

Run the following command to give execute permission to the script:


chmod +x install_registry.sh
Run the script:


./install_registry.sh
The script will install the required tools and set up the Docker registry. Follow the on-screen prompts.

## macOS (Zsh)
Open a terminal.

Run the following command to give execute permission to the script:
```
chmod +x install_registry.zsh
```
Run the script:

```
./install_registry.zsh
```

The script will install the required tools and set up the Docker registry. Follow the on-screen prompts.

Important Notes
Self-signed certificates might cause browser warnings and client issues. For production, consider using trusted certificates.
Adjust the configurations in the script as needed for your environment.