data "azurerm_resource_group" "test" {
  name = "tfmulti"
}

locals {
  region = var.environment == "prd" ? "East US" : var.environment == "stg" ? "West US" : var.environment == "dev" ? "Central US" : "East US"  # Default location if none of the conditions match
} 

resource "azurerm_virtual_network" "tfvnetmulti" {
  name                = "${var.environment}-tfvnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.region
  resource_group_name = data.azurerm_resource_group.test.name
}

resource "azurerm_subnet" "tfvnetsub" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.tfvnetmulti.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "testpubid" {
  count               = var.instance_count
  name                = "${var.environment}-tflinuxpublicip-${count.index + 1}"
  location            = azurerm_virtual_network.tfvnetmulti.location
  resource_group_name = data.azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "testnic" {
  
  count               = var.instance_count
  name                = "${var.environment}-tflinuxpublicip-${count.index + 1}"
  location            = azurerm_virtual_network.tfvnetmulti.location
  resource_group_name = data.azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tfvnetsub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testpubid[count.index].id
  }
}


/*resource "azurerm_network_security_group" "testnsg" {
  name                = "tflinuxnsg"
  location            = azurerm_virtual_network.tfvnetmulti.location
  resource_group_name = data.azurerm_resource_group.test.name
  security_rule {
    name                       = "Allowhttp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "staging"
  }
}*/
resource "azurerm_linux_virtual_machine" "testvm" {
  count               = var.instance_count
  name                = "${var.environment}-tflinuxvm-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.test.name
  location            = azurerm_virtual_network.tfvnetmulti.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.testnic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("tf-key.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  #custom_data = filebase64("install.sh")
    tags = {
    Environment = var.environment
    Project     = "TerraformDemo"
  }
}

