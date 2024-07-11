---
title: GCP Google Cloud Platform - Install CLI Tools
description: Learn to install cli tools required for using Terraform on GCP
---

## Step-01: Introduction
1. Install gcloud CLI 
2. Install Terraform CLI
3. Install VSCode Editor
4. Install Terraform Pluging for VSCode
5. Implement above 4 steps in both MacOS and WindowsOS

## Step-02: MacOS: Install gcloud cli and verify
### Step-02-01: Install gcloud cli
- [Install gcloud cli](https://cloud.google.com/sdk/docs/install-sdk#mac)
```t
# Verify Python Version (Supported versions are Python 3 (3.5 to 3.11, 3.11 recommended)
python3 -V

# Determine your machine hardware 
uname -m

# Create Folder
mkdir gcloud-cli-software
cd gcloud-cli-software

# Download gcloud cli based on machine hardware 
## Important Note: Download the latest version available on that respective day
Dowload Link: https://cloud.google.com/sdk/docs/install-sdk#mac

## As on today the below is the latest version (x86_64 bit)
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-479.0.0-darwin-x86_64.tar.gz

# Unzip binary
ls -lrta
tar -zxf google-cloud-cli-479.0.0-darwin-x86_64.tar.gz
cd 

# Run the install script with screen reader mode on:
./google-cloud-sdk/install.sh --screen-reader=true
```

### Step-02-02: Verify gcloud cli version
```t
# Open new terminal
AS PATH is updated, open new terminal

# gcloud cli version
gcloud version
```

### Step-02-03: Intialize gcloud CLI in local Terminal 
```t
# Initialize gcloud CLI
./google-cloud-sdk/bin/gcloud init

# List accounts whose credentials are stored on the local system:
gcloud auth list

# List the properties in your active gcloud CLI configuration
gcloud config list

# View information about your gcloud CLI installation and the active configuration
gcloud info

# gcloud config Configurations Commands (For Reference)
gcloud config list
gcloud config configurations list
gcloud config configurations activate
gcloud config configurations create
gcloud config configurations delete
gcloud config configurations describe
gcloud config configurations rename

# Configure GCP Credentials (ADC: Application Default Credentials)
# IMPORTANT: MANDATORY FOR TERRAFORM COMMANDS TO WORK WITH GCP FROM OUR LOCAL TERMINAL
gcloud auth application-default login
```

### Step-02-04: Install Terraform CLI using Homebrew
- [Download Packages](https://developer.hashicorp.com/terraform/install#darwin)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
```t
# Install the Hashicorp tap
brew tap hashicorp/tap

# Install terraform 
brew install hashicorp/tap/terraform

# Update to the latest version of Terraform
brew update
brew upgrade hashicorp/tap/terraform
```

### Step-02-05: Install Terraform CLI - Manually
- [Download Packages](https://developer.hashicorp.com/terraform/install#darwin)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
```t
# Copy binary zip file to a folder
mkdir /Users/<YOUR-USER>/Documents/terraform-install
COPY Package to "terraform-install" folder

# Unzip
unzip <PACKAGE-NAME>
unzip terraform_1.8.5_darwin_amd64.zip

# Copy terraform binary to /usr/local/bin
echo $PATH
mv terraform /usr/local/bin

# Verify Version
terraform version

# To Uninstall Terraform (NOT REQUIRED)
rm -rf /usr/local/bin/terraform
```

### Step-02-06: MACOS: IDE for Terraform - VS Code Editor
- [Microsoft Visual Studio Code Editor](https://code.visualstudio.com/download)
- [Hashicorp Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)


## Step-03: WindowsOS: Install gcloud cli and verify
### Step-03-01: Install gcloud cli on WindowsOS
- [Install gcloud cli on WindowsOS](https://cloud.google.com/sdk/docs/install-sdk#windows)
```t
## Important Note: Download the latest version available on that respective day
Dowload Link: https://cloud.google.com/sdk/docs/install-sdk#windows

## Run the Installer
GoogleCloudSDKInstaller.exe
```

### Step-03-02: Verify gcloud cli version
```t
# gcloud cli version
gcloud version
```

### Step-03-03: Intialize gcloud CLI in local Terminal 
```t
# Initialize gcloud CLI
gcloud init

# List accounts whose credentials are stored on the local system:
gcloud auth list

# List the properties in your active gcloud CLI configuration
gcloud config list

# View information about your gcloud CLI installation and the active configuration
gcloud info

# gcloud config Configurations Commands (For Reference)
gcloud config list
gcloud config configurations list
gcloud config configurations activate
gcloud config configurations create
gcloud config configurations delete
gcloud config configurations describe
gcloud config configurations rename

# Configure GCP Credentials (ADC: Application Default Credentials)
gcloud auth application-default login
```

### Step-03-04: Install Terraform CLI
- [Download Terraform](https://developer.hashicorp.com/terraform/install#windows)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
```t
# Install the Hashicorp tap
choco install terraform
```
- Unzip the package
- Create new folder `terraform-bins`
- Copy the `terraform.exe` to a `terraform-bins`
- Set PATH in windows 

### Step-03-05: Windows: IDE for Terraform - VS Code Editor
- [Microsoft Visual Studio Code Editor](https://code.visualstudio.com/download)
- [Hashicorp Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)



