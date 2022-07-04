provider "azurerm" {

features {}

skip_provider_registration = true

subscription_id = "2ed1a4b1-8d67-48fb-8ef6-0d8fa4ab6a5d"

}

variable "username" {

default = "testuser"

}



variable "password" {

default = "Atchaya22@"

}



resource "azurerm_network_interface" "main" {

name = "Anush-nic"

location = "centralindia"

resource_group_name = "MarCCP2022-sandbox"



ip_configuration {

name = "testconfiguration1"

subnet_id = "/subscriptions/2ed1a4b1-8d67-48fb-8ef6-0d8fa4ab6a5d/resourceGroups/MarCCP2022-sandbox/providers/Microsoft.Network/virtualNetworks/TempSandboxVnet/subnets/first"

private_ip_address = "10.2.1.41"

private_ip_address_allocation = "Static"



public_ip_address_id = azurerm_public_ip.public_ip.id



}

}



resource "azurerm_virtual_machine" "main" {

name = "Anush-vm"

location = "centralindia"

resource_group_name = "MarCCP2022-sandbox"

network_interface_ids = [azurerm_network_interface.main.id]

vm_size = "Standard_B2s"

# Uncomment this line to delete the OS disk automatically when deleting the VM

# delete_os_disk_on_termination = true



# Uncomment this line to delete the data disks automatically when deleting the VM

# delete_data_disks_on_termination = true



storage_image_reference {

publisher = "Canonical"

offer = "UbuntuServer"

sku = "16.04-LTS"

version = "latest"

}

storage_os_disk {

name = "Atc"

caching = "ReadWrite"

create_option = "FromImage"

managed_disk_type = "Standard_LRS"

}

os_profile {

computer_name = "atchaya"

admin_username = "testuser"

admin_password = "Atchaya22@"

}

os_profile_linux_config {

disable_password_authentication = false

}

tags = {

environment = "staging"

}

}




resource "azurerm_public_ip" "public_ip" {

name = "Atc-pip"

location = "centralindia"

resource_group_name = "MarCCP2022-sandbox"

allocation_method = "Dynamic"

}





resource "null_resource" "tst" {



connection {

type = "ssh"

user = var.username

password = var.password

host = azurerm_public_ip.public_ip.ip_address



}



provisioner "file" {

source = "./security.groovy"

destination = "/tmp/security.groovy"

}



provisioner "file" {

source = "./script.sh"

destination = "/tmp/script.sh"

}



provisioner "remote-exec" {

inline = [

"cd /tmp",

"sh script.sh",



]

}

depends_on = [

time_sleep.wait_30_seconds

]

}




resource "time_sleep" "wait_30_seconds" {

depends_on = [azurerm_virtual_machine.main]



create_duration = "15s"

}