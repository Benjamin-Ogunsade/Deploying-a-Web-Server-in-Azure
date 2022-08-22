# Deploying a Web Server in Azure: Udacity DevOps Project 1

# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone the startee repository

2. Create your infrastructure as code


### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
To clone the starter repository

```
git clone github_rep_ssh_clone_link
````


##### Step 1: Create a policy that denies the creation of the index resources which don't have tags.

This policy definition was implemented with this [model](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F871b6d14-10aa-478d-b590-94f262ecfa99). 

The aim is to ensure that all indexed resourcs in my subscription have tags and deny deployment if they do not.

The policy definition was declared in a PolicyRule.json file only and every other parameters were parsed into the policy definition via the command option flags.

Here are a few lines of AzureCLI Bash scripts to get the policy up and runnnig:


First, a policy definition CLI variable is declared:

````
$definition = New-AzPolicyDefinition -Name 'deny-deployment-of-all-indexed-resources-devoid-of-tag' -DisplayName 'Require a tag on resources' -Description 'Enforces existence of a tag only on resources, but not applied to resource groups.' -Policy './myPolicy.json' -Mode 'Indexed' -Metadata '{"version":"1.0.1","category":"Tags"}' -Parameter '{"tagName":{"type":"String","metadata":{"displayName":"environment","description":"environment"}}}'

````

Second, an policy assignment variable is also created. This variable takes the aforementioned policy definition variable as one of its flag options parameter


````
$assignment = New-AzPolicyAssignment -Name 'deny-deployment-of-all-indexed-resources-devoid-of-tag' -PolicyDefinition $definition
````

Next, the new policy definition' assignment is being applied:

````
echo $assignment
````

the screenshoot of the newly applied policy assignment is given below:


##### Step X: Instruction to run the Packer template

##### Step X: Customizing the vars.tf file for us


##### Step X: Instruction to run the Terraform template


##### Deploying the infrastructure

Screenshot for Terraform Apply


### Output
**Your words here**
