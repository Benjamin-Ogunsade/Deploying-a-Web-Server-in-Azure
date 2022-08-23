variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus"
}

variable "vm_username" {
	description = "User name to use as the VM account"
	default  = "testadmin"
}
	
variable "vm_password" {
	description = "Password to use to the VM account"
	default  = "Password1234!"
}

variable "image_id_ref" {
  description = "The image_id of the managed_image created by packer"
  default     = "/subscriptions/157081ad-2288-4aa4-b6d0-69f2165b7326/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/myPackerImage"
}

variable "vm_count" {
	description = "Number of Virtual Machines for this deployment"
	type  = string
}

variable "tags" {
    description = "Map of the tags to use for the created resource"
	type  = map(string)
	default = {
		environment = "environment"
	}
}