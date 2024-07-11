---
title: GCP Google Cloud Platform - Implement DevOps for Terraform Code in GCP
description: Learn to implement DevOps for Terraform Code in GCP
---

## Step-01: Introduction
- Implement DevOps pipeline using 
  - GitHub 
  - GCP Cloud Build App for GitHub 
  - GCP Cloud Build Service
- We are going to use dev and prod environments in this demo. You can extend it to as many environments as needed. 
- We are going to use Terraform Modules concept for a VM Instance which needs changes that will be implemented via DevOps Pipeline using GCP Cloud Build  

## Step-02: Review or Create GIT Repo Files
### Step-02-01: Modules Folder
- Copy the **modules folder** from previous demo (Section: 29-Terraform-Build-Custom-Module)

### Step-02-02: Dev environment in Environments Folder: dev
1. Copy the **terraform-manifests folder** from previous demo (Section: 29-Terraform-Build-Custom-Module) and rename folder to dev (envirionments/dev)
2. **envirionments/dev/c1-versions.tf:** ensure we have the backend block configured as **prefix = "env/dev"**
3. **Update your bucket name present in your GCP Account:** `bucket = "gcplearn9-tfstate"`
```hcl
# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.36.0"
    }
  }
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "env/dev"
  }  
}
```
3. **terraform.tfvars:** Ensure environment is **environment     = "dev"**
```hcl
gcp_project   = "gcplearn9"
gcp_region1   = "us-central1"
machine_type  = "e2-micro"
environment     = "dev"
business_divsion = "hr"
```

### Step-02-03: Prod environment in Environments Folder: prod
1. Copy the **terraform-manifests folder** from previous demo (Section: 29-Terraform-Build-Custom-Module) and rename folder to prod (envirionments/prod)
2. **envirionments/prod/c1-versions.tf:** ensure we have the backend block configured as **prefix = "env/prod"**
3. **Update your bucket name present in your GCP Account:** `bucket = "gcplearn9-tfstate"`
```hcl
# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.36.0"
    }
  }
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "env/prod"
  }  
}
```
3. **terraform.tfvars:** Ensure environment is **environment     = "prod"**
```hcl
gcp_project   = "gcplearn9"
gcp_region1   = "us-central1"
machine_type  = "e2-micro"
environment     = "prod"
business_divsion = "hr"
```
### Step-02-04: Review cloudbuild.yaml
```yaml
steps:
- id: 'branch name'
  name: 'alpine'
  entrypoint: 'sh'  
  args: 
  - '-c'
  - | 
      echo "***********************"
      echo "$BRANCH_NAME"
      echo "***********************"

- id: 'tf init'
  name: 'hashicorp/terraform:1.9.0'
  entrypoint: 'sh'
  args: 
  - '-c'
  - |
      if [ -d "environments/$BRANCH_NAME/" ]; then
        cd environments/$BRANCH_NAME
        terraform init
      else
        for dir in environments/*/
        do 
          cd ${dir}   
          env=${dir%*/}
          env=${env#*/}
          echo ""
          echo "*************** TERRAFORM INIT ******************"
          echo "******* At environment: ${env} ********"
          echo "*************************************************"
          terraform init || exit 1
          cd ../../
        done
      fi 

# [START tf-plan]
- id: 'tf plan'
  name: 'hashicorp/terraform:1.9.0'
  entrypoint: 'sh'
  args: 
  - '-c'
  - | 
      if [ -d "environments/$BRANCH_NAME/" ]; then
        cd environments/$BRANCH_NAME
        terraform plan
      else
        for dir in environments/*/
        do 
          cd ${dir}   
          env=${dir%*/}
          env=${env#*/}  
          echo ""
          echo "*************** TERRAFORM PLAN ******************"
          echo "******* At environment: ${env} ********"
          echo "*************************************************"
          terraform plan || exit 1
          cd ../../
        done
      fi 
# [END tf-plan]

# [START tf-apply]
- id: 'tf apply'
  name: 'hashicorp/terraform:1.9.0'
  entrypoint: 'sh'
  args: 
  - '-c'
  - | 
      if [ -d "environments/$BRANCH_NAME/" ]; then
        cd environments/$BRANCH_NAME      
        terraform apply -auto-approve
      else
        echo "***************************** SKIPPING APPLYING *******************************"
        echo "Branch '$BRANCH_NAME' does not represent an official environment."
        echo "*******************************************************************************"
      fi
# [END tf-apply]      
```

## Step-03: GitHub: Create new GitHub Repository
- Go to GitHub -> Repositories Tab -> Click on **NEW**
- **Repository name:** terraform-gcp-devops
- **Description:** Implement DevOps Pipelines for Terraform Configs on GCP (Google Cloud Platform)
- **Type:** Private
- **Initialize this repository with:** Add a README file
- Click on **Create Repository** 

## Step-04: Local Desktop: Install Git Client and Configure GitHub SSH Keys
- Optional step, if you already familiar with github please ignore
### Step-04-01: Install Git Client
- [Install Git Client](https://git-scm.com/downloads)
```t
# Mac
brew install git

# Windows
1. Download and install
```
### Step-04-02: [Generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```t
### STEPS FOR MACOS ###
# Verify if Authentication is successful
ssh -T git@github.com

# Create New SSH Key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Create new SSH Key (If you are using a legacy system that doesn't support the Ed25519 algorithm)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Start SSH Agent
eval "$(ssh-agent -s)"

# Verify if file exists
open ~/.ssh/config

# Create file if doesn't exists
touch ~/.ssh/config

# Open config file, Add below text and save it
vi ~/.ssh/config

## Content in file ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain no
  IdentityFile ~/.ssh/id_ed25519
```
### Step-04-03: [Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui)
- [Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui)
```t
# Copy the content from public key file
cat $HOME/.ssh/id_ed25519.pub

# Go to GitHub -> Settings -> SSH and GPG Keys -> New SSH Key
TITLE: mac-mini-1
KEY: COPY the public key file content (id_ed25519.pub)
```

### Step-04-04: [Testing SSH Connection](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
- [Testing SSH Connection](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
```t
# Verify if Authentication is successful
ssh -T git@github.com
```

## Step-05: Local Desktop: Clone GitRepo and Update all the files dicussed in Step-02
```t
# Clone GitHub Repository
git clone git@github.com:stacksimplify/terraform-gcp-devops.git

# Copy Files from "GIT-Repo-Files" folder
1. environmets folder
2. modules folder
3. cloudbuild.yaml
4. .gitignore
5. git-deploy.sh

# Commit and Push files to remote git repo
git status
git commit -am "Base commit"
git push
```

## Step-06: GitHub: Configure GCP Cloud Build on GitHub
- Go to link [GitHub Marketplace - Google Cloud Build](https://github.com/marketplace/google-cloud-build)
- Click on **Set up with Google Cloud Build**
- **Only select repositories:** stacksimplify/terraform-gcp-devops
- Click on **Install**
- Login to Google Cloud and Click on **Authorize Google Cloud Build**
- **Select project in GCP:** gcplearn9


## Step-07: GCP Cloud Build: Create HOST Connection
- Go to Cloud Build -> Repositories -> 2nd Gen -> **CREATE HOST CONNECTION**
- **Select Provider:** GitHub
- **Configure Connection:** 
  - **Region:** us-central1
  - **Name:** mygithub-connection1
  - Click on **CONNECT**
  - Click on **CONTINUE**
  - **Use an existing GitHub installation:** 
    - **Installation:** stacksimplify
    - Click on **CONFIRM**

## Step-08: GCP Cloud Build: Link Repository
- Go to Cloud Build -> Repositories -> 2nd Gen -> mygithub-connection1 -> **LINK REPOSITORY** 
- **Connection:** mygithub-connection1
- **Repository:** stacksimplify/terraform-gcp-devops
- **Repository name:** Generated
- Click on **LINK**

## Step-09: GCP Cloud Build: Create Trigger
- Go to Cloud Build -> Triggers -> **CREATE TRIGGER**
- **Name:** myapp1-trigger1
- **Region:** us-central1
- **Description:** MyApp1 Cloud Build Trigger
- **Event:**
  - **Repository event that invokes trigger:** Push to a branch
- **Source:** 
  - **Repository generation:** 2nd gen
  - **Repository:** stacksimplify-terraform-gcp-devops
  - **Branch:** .* (any branch)
- **Configuration:** 
  - **Type:** Cloud Build configuration file (yaml or json)
- **Location:** 
  - **Repository:** stacksimplify-terraform-gcp-devops (GitHub)
  - **Cloud Build configuration file location:** cloudbuild.yaml
- **Advanced:**
  - **Approval:** Require approval before build executes
- REST ALL LEAVE TO DEFAULTS
- Click on **CREATE**

## Step-10: GitHub: Create Dev and Prod branches
- **Pre-requisite:** Please ensure c1-versions.tf in Dev and Prod environments, you have updated your GCP Cloud storage bucket name to store Terraform state files as part of step-02 of this demo
```hcl
# Dev Environment
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "env/dev"
  } 
# Prod Environment
  backend "gcs" {
    bucket = "gcplearn9-tfstate"
    prefix = "env/prod"
  }   
```
- Go to GitHub -> terraform-gcp-devops -> main -> View all branches
- Click on **New branch** 
  - **New branch name:** dev
  - **Source:** main
  - click on **Create new branch**
- Click on **New branch** 
  - **New branch name:** prod
  - **Source:** main
  - click on **Create new branch**

## Step-11: GCP Cloud Build: Approve Dev and Prod base builds
- Go to Cloud Build -> History 
### Step-11-01: Dev Build: Approve
- Approve Dev Build
- Review Build steps (tf init, tf plan, tf apply) and Build Summary
- Verify Terraform State file in Cloud Storage Bucket
- Verify Infra for Dev environment
  - VPC
  - Firewall Rules
  - VM Instance
  - VM Instance Disk size  
  - Access Application: http://<VM-External-IP>
### Step-11-02: Prod Build: Approve
- Approve Prod Build
- Review Build steps (tf init, tf plan, tf apply) and Build Summary
- Verify Terraform State file in Cloud Storage Bucket
- Verify Infra for prod environment
  - VPC
  - Firewall Rules
  - VM Instance
  - VM Instance Disk size
  - Access Application: http://<VM-External-IP>


## Step-12: GitHub: NEW FEATURE BRANCH: Update VM Instance Boot disk size from 10 to 20 GB
### Step-12-01: GitHub: Make a change with new branch
- Go to dev branch -> terraform-gcp-devops/modules/vminstance
/main.tf -> EDIT IN PLACE
- COMMENT `#size = 10` and UNCOMMENT `size = 20`
```hcl
# Resource Block: Create a single Compute Engine instance
resource "google_compute_instance" "myapp1" {
  name         = var.vminstance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.firewall_tags
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      #size = 10
      size = 20
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")
  network_interface {
    subnetwork = var.subnetwork   
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```
- Click on **COMMIT CHANGES**
- **COMMIT MESSAGE:** Update VM Instance Boot from 10GB to 20GB
- **SELECT OPTION:** Create a new branch for this commit and start a pull request
- **NEW BRANCH NAME:** stacksimplify-patch-1
- Click on **Propose changes**
- Click on **Create pull request**
### Step-12-02: GCP Cloud Build: Approve Build for branch: stacksimplify-patch-1
- Go to **Cloud Build** -> **Approve Build**
- Review Build steps (tf init, tf plan, tf apply) and Build Summary
- **Observation:** 
  - **tf plan:** tf plan will run for both dev and prod folders with the change we have made in the branch **stacksimplify-patch-1**
  - **Important Note:** The build checks whether the $BRANCH_NAME variable matches any environment folder. If so, Cloud Build executes `terraform plan` for that environment. Otherwise, Cloud Build executes terraform plan for all environments to make sure that the proposed change is appropriate for all of them. If any of these plans fail to execute, the build fails.
  - Review the plan to see what will happen for both environments (Dev, prod)
  - Based on the disk size change, it will replace the VM. 
    - **module.myvminstance.google_compute_instance.myapp1 must be replaced**
    - **Plan: 1 to add, 0 to change, 1 to destroy.**
  - **tf apply:** tf apply will run only for environment name and branch name matches (example: currently only for dev and prod)
  - **Important Note:** Similarly, the `terraform apply` command runs for environment branches, but it is completely ignored in any other case.

### Step-12-03: GitHub: Verify the Checks on GitHub
- We should see **All checks have passed** message

## Step-13: GitHub: Promote changes to dev environment and Verify changes applied in Dev environment using Cloud Build
### Step-13-01: GitHub: Promote changes to dev environment
- Go to GitHub -> terraform-gcp-devops -> pull requests 
- Click on the pull request just created
- Review statement **stacksimplify wants to merge 1 commit into dev from stacksimplify-patch-1**
- Click on **Merge pull request**
- Click on **Config merge** 
- You should see message **Pull request successfully merged and closed**
- Verify GCP Cloud Build if any build triggered for **dev** branch 
### Step-13-02: GCP Cloud Build: Review and approve Dev Build
- Approve Dev Build
- Review Build steps (tf init, tf plan, tf apply) and Build Summary
- Verify Infra for dev environment
  - VM Instance: **SHOULD BE REPLACED WITH NEW VM**
  - VM Instance Disk size: **IT SHOULD BE 20 GB**
  - Access Application: http://<VM-External-IP>

## Step-14: GitHub: Promote changes to prod environment and Verify changes applied in Prod environment using Cloud Build
### Step-14-01: GitHub: Promote changes to prod environment
- Go to GitHub -> terraform-gcp-devops -> pull requests 
- Click **New pull request** 
- **base:** prod
- **compare:** dev
- Review the changes
- Click on **Create pull request**
- **Title:** Promoting VM InstanceDisk size changes 10GB to 20GB to prod
- Click on **Create pull request**
- Click on **Merge pull request**
- Click on **Confirm merge**
- You should see message **Pull request successfully merged and closed**
- Verify GCP Cloud Build if any build triggered for **prod** branch 

### Step-14-02: GCP Cloud Build: Review and approve Prod Build
- Approve Prod Build
- Review Build steps (tf init, tf plan, tf apply) and Build Summary
- Verify Infra for prod environment
  - VM Instance: **SHOULD BE REPLACED WITH NEW VM**
  - VM Instance Disk size: **IT SHOULD BE 20 GB**
  - Access Application: http://<VM-External-IP>

## Step-15: Clean-Up
### Step-15-01: Delete VM Instances
- Dev and prod VM Instances
### Step-15-02: Delete VPCs
- Dev and prod VPC
### Step-15-03: Delete State files in Cloud Storage Bucket
- env/dev
- env/prod
### Step-15-04: Cloud Build: Delete Trigger, Repository and Host Connection
- Delete Trigger
- Delete Repository
- Delete Host Connection
### Step-15-05: Cloud Build App Uninstall 
- Go to GitHub -> Settings -> Applications -> Uninstall
### Step-15-06: Cloud Build App Unsubscribe in GitHub
- Go to GitHub -> Settings -> Billing and Plans -> Plans and Usage -> Cancel Plan
