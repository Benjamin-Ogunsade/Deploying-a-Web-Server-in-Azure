provider "azurerm" {
  features {}
}

#Load existing resource group
#load the existing because this acc lacks autorization to create a new resource group but can make reference to the one created by default  
data "azurerm_resource_group" "example" {
  name = "Azuredevops"
  #location = var.location
}

output "id" {
  value = data.azurerm_resource_group.example.id
  sensitive = true
}

#Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/24"]
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

#Create subnet on the above VNet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
  address_prefixes     = azurerm_virtual_network.example.address_space
}

#Create a Network Security Group with some rules
resource "azurerm_network_security_group" "example" {
  resource_group_name   = data.azurerm_resource_group.example.name
  location              = data.azurerm_resource_group.example.location
  name   				= "${var.prefix}-nsg"

  security_rules {
	  name                   = "allowaccesstoVMs"
	  priority               = 101
	  direction              = "Inbound"
	  access                 = "Allow"
	  protocol               = "tcp"
	  source_port_range      = "*"
	  source_address_prefix	 = "*"
	  destination_port_range = "*"
	  destination_address_prefix = azurerm_virtual_network.example.address_space
	  description            = "allow access to other VMs on the subnet"
	  
	  #by default all other inbound internet access are prohibited
    }
  
  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.example]
}

#Create a Network Interface
resource "azurerm_network_interface" "example" {
  count 			  = var.vm_count #create 'x' similar nic instances 
  name                = "${var.prefix}-${count.index}-nic" #count.index refers to individual instances ready/set/prepared to be created
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}


#Create Public IP
resource "azurerm_public_ip" "example" {
  name                = "PublicIPForLB"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  allocation_method   = "Static"
  domain_name_label   = "public-ip-address1"
  ip_version          = "IPv4"

  tags = {
    environment = "Production"
    owner       = "Ops"
  }
}


#Create a Load Balancer
resource "azurerm_lb" "example" {
  name                = "${var.prefix}-LoadBalancer"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
  
  tags = var.tags
}

#Load balancer backend pool [which will be in association for the network interface and the load balancer]

resource "azurerm_lb_backend_address_pool" "example" {
  resource_group_name = data.azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
}

#Because this project entails a public load balancer, there will be need to add load balancing translation rules

resource "azurerm_lb_nat_rule" "example" {
  resource_group_name            = data.azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "HTTPSAccess"  #we allow only secure http
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "azurerm_lb.example.frontend_ip_configuration.public_ip_address_id"
}


resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count 				  = var.vm_count
  network_interface_id    = element(azurerm_network_interface.example.*.id, count.index)
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

#Create a virtual machine availability set
resource "azurerm_availability_set" "example" {
  name                = "{var.prefix}avset"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  platform_fault_domain_count = 2
  platform_update_domain_count = 2
  managed = true 
  tags = var.tags
}

#Using the data source to access information about the packer created image
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/images
data "azurerm_image" "packerimage" {
  name                = "myPackerImage"
  resource_group_name = "Azuredevops"
}

output "image_id" {
  value = "${var.image_id_ref}"
}

#create a virtual machine based on the custom image 
resource "azurerm_virtual_machine" "example" {
  count 						              = var.vm_count 
  name                            = "${var.prefix}-VM-${count.index}"
  resource_group_name             = data.azurerm_resource_group.example.name
  location                        = data.azurerm_resource_group.example.location
  availability_set_id 			      = "azurerm_availability_set.example.id" #The ID of the Availability Set in which the Virtual Machine should exist
  vm_size                         = "Standard_D2s_v3"
  delete_os_disk_on_termination   = true
  delete_data_disks_on_termination = true

  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ] 								#creates a nic id for individualinstance of the nic resource
  
  storage_image_reference {
    id = "${data.azurerm_image.packerimage.id}"
  }
  storage_os_disk {
    name              = "${var.prefix}_OS_1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-AppVM"
    admin_username = "${var.vm_username}"
    admin_password = "${var.vm_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false  
  } 
  tags = {
    environment = "staging"
  }
  
}