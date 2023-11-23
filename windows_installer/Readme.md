# Cluster Setup Script (PowerShell)

This script is designed to simplify the setup of Kubernetes clusters using KinD (Kubernetes in Docker), install prerequisite software, and deploy a test application. It is intended for Windows environments.

## Usage

1. **Clone the Repository**:

   Clone this repository to your local machine.

   ```bash
   git clone https://github.com/your-username/cluster-setup-script.git
   cd cluster-setup-script

### Open a PowerShell Console as Administrator:

Press Win + X.
Choose "Windows Terminal" or "Windows PowerShell (Admin)" from the menu.
Set Execution Policy (if needed):

If you haven't already set the execution policy to allow running scripts, use this command:
```
Set-ExecutionPolicy RemoteSigned

```

Confirm with "Y" if prompted.

### Run the Script:

Execute the PowerShell script by entering its filename with the .ps1 extension, including the .\ prefix:

```
.\ClusterSetup.ps1

```

Follow the on-screen prompts to select the desired actions.

## Dependencies
Before running the script, ensure that the following dependencies are installed:

* Docker for Windows: Docker is required to create Kubernetes clusters. If it's not installed, the script will attempt to install it.

* KinD (Kubernetes in Docker): The script installs KinD for cluster creation if it's not found on your system.

* Helm: Helm is a package manager for Kubernetes. The script will install Helm if it's not found.

* chocolatey (optional): If you haven't already installed Chocolatey (a package manager for Windows), the script will attempt to install it as part of the Docker installation process.

## Additional Notes

Ensure you have administrative privileges when running the script to allow installation of software components and make necessary configuration changes.

Review and customize the script as needed before running it. Some settings, such as port numbers and file paths, can be adjusted within the script itself.

Make sure your PowerShell environment variables (e.g., PATH) are correctly set for installed tools to work as expected.

Carefully review the packages and configurations that the script installs.

Please consult the software documentation or respective websites for more detailed information on the installed tools.

The script was designed for Windows environments. If you are using a different operating system, modifications may be required.

