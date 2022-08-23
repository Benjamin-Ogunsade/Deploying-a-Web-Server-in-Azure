# Deploying a Web Server in Azure: Udacity DevOps Project 1

## Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone the starter repository

2. Create your infrastructure as code


### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
To clone the starter repository, a public ssh key needs to be generated for remote authentication to GitHub, via the CLI comnand

````
ssh-keygen -t rsa
````
![image](https://user-images.githubusercontent.com/28298236/185976602-ab944906-2b2b-455a-b01b-a0d39e760a6a.png)

The above command generates the public key which is recovered via:

````
cat /home/odl_user/.ssh/id_rsa.pub
````
![image](https://user-images.githubusercontent.com/28298236/185976911-ec54aa80-c6ef-446e-b43a-c01fde7f14ac.png)

This is copied and pasted [here](https://github.com/settings/keys), select "New SSH key", give it a suitable title e.g "SSH-key-for-Udacity-Access-Lab". Validate it.

Thence, the git clone command will run, unhindered.


````
git clone git@github.com:Benjamin-Ogunsade/Project-1.git
````

![image](https://user-images.githubusercontent.com/28298236/185977312-93211a93-712d-4f06-9cd1-a7315e2d8f38.png)


With the remote repository cloned to the Azure CLI local machine, one could modify files remotely.


### Step 1: Create a policy that denies the creation of the index resources which don't have tags.

This policy definition was implemented with this [model](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F871b6d14-10aa-478d-b590-94f262ecfa99). 

The aim is to ensure that all indexed resourcs in my subscription have tags and deny deployment if they do not.

Firstly, you are admonished to place the policy definition myPolicy.json in the home directory. This file uniquely contains the Policy Rule while every other parameters were parsed into the policy definition and assignment commands via option flags.

Do endeavour to be in the right directory on your CLI for the commands to run correctly. Here are a few lines of AzureCLI Powershell scripts to get the policy up and runnnig:

Next, a policy definition CLI variable is declared:


````
$definition = New-AzPolicyDefinition -Name 'tagging-policy' -DisplayName 'Require a tag on resources' -Description 'Enforces existence of a tag only on resources, but not applied to resource groups.' -Policy './myPolicy.json' -Mode 'Indexed' -Metadata '{"version":"1.0.1","category":"Tags"}' -Parameter '{"tagName":{"type":"String","metadata":{"displayName":"environment","description":"environment"}}}'
````

Then, a policy assignment variable is also created. This variable takes the aforementioned policy definition variable as one of its flag options parameter

````
$assignment = New-AzPolicyAssignment -Name 'tagging-policy' -PolicyDefinition $definition
````

Next, the new policy definition' assignment is being applied:

````
echo $assignment
````

![image](https://user-images.githubusercontent.com/28298236/185986047-47d093d1-8515-4894-ba70-0e32a668f90c.png)

The newly applied policy assignment is seen by running the command: 
````
az policy assignment list
````
Producing:
![image](https://user-images.githubusercontent.com/28298236/185987562-2a232816-1c76-4d37-b0da-b2d5566a922c.png)


### Step 2: Instruction to run the Packer template

In order to support application deployment, we need to create a packer image that is DRY and reproducable, to be leveraged upon in the Terraform template.


To create a Server image  using Packer and ensuring that the provided application is included in the template.
The file server.json contains the code detailing the specifications of the to be deployed' Server image.

Note that Powershell commands are used below to declare the environment variables that would ben needed during the creation of the packer image. The assigned values below are rendered fictitious shortly. The values below are customizable based on the Azure subscription credentials assignedd to this account.

````
Set-Item -Path Env:\ARM_CLIENT_ID -Value "b2af4b8e-d619-499f-a9a8-3f150b40c48b"
Set-Item -Path Env:\ARM_CLIENT_SECRET -Value "zvo8Q~H84fvlaTM3mtJ1STeKdqZmLueQQKcWgdm6"
Set-Item -Path Env:\ARM_SUBSCRIPTION_ID -Value "157081ad-2288-4aa4-b6d0-69f2165b7326"
Set-Item -Path Env:\tenant_id -Value "f958e84a-92b8-439f-a62d-4f45996b6d07"
````

The packer image has been created as seen on the Az CLI and Az Portal respectively:
![image](https://user-images.githubusercontent.com/28298236/186036585-06ef740c-d2ea-4dd9-8436-b56cb2846aef.png)

![image](https://user-images.githubusercontent.com/28298236/186037315-46025d52-8dd3-44a1-b75b-419210579109.png)

The created packer image is named myPackerImage.


### Step 3: Customizing the vars.tf file for us


### Step 4: Instruction to run the Terraform template
Once the Packer image is successfully deployed, Terraform is used to deploy the infrastructure (making sure to run terraform plan with the -out flag, and save the plan file with the name solution.plan).

Remember to recover the ManagedImageId and ManagedImageName that would be needed in the vars.tf and main.tf files respectively.

### Deploying the infrastructure

Screenshot for Terraform Apply


### Output
**Your words here**
