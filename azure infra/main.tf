data "azurerm_resource_group" "test" {
  name = "manualtest"
}
data "azurerm_virtual_network" "nwtest" {
  name                = "linuxtest-vnet"
  resource_group_name = data.azurerm_resource_group.test.name
}

data "azurerm_subnet" "subtest" {
  name                 = "default"
  resource_group_name  = data.azurerm_resource_group.test.name
  virtual_network_name = data.azurerm_virtual_network.nwtest.name
}
resource "azurerm_network_interface" "testnic" {
  name                = "tflinuxnic"
  location            = data.azurerm_virtual_network.nwtest.location
  resource_group_name = data.azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subtest.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testpubid.id
  }
}
resource "azurerm_public_ip" "testpubid" {
  name                = "tflinuxpublicip"
  location            = data.azurerm_virtual_network.nwtest.location
  resource_group_name = data.azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "testnsg" {
  name                = "tflinuxnsg"
  location            = data.azurerm_virtual_network.nwtest.location
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
}
resource "azurerm_linux_virtual_machine" "testvm" {
  name                = "tflinuxvm"
  resource_group_name = data.azurerm_resource_group.test.name
  location            = data.azurerm_virtual_network.nwtest.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/Users/snehsrivastava/terraform_practice/secrets/tf-key.pub")
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
  custom_data = filebase64("install.sh")

}

