resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource   "azurerm_resource_group"   "rg"   { 
   name   =   var.rg_name
   location   =   "westeurope" 
 } 

 resource   "azurerm_virtual_network"   "myvnet"   { 
   name   =   var.vnet_name
   address_space   =   var.vnet_address_space
   location   =   "westeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   var.subnet_name
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.myvnet.name 
   address_prefix   =   var.subnet_address_space 
 } 

 resource   "azurerm_public_ip"   "myvm1publicip"   { 
   name   =   "pip3" 
   location   =   "westeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 

 resource   "azurerm_network_interface"   "myvm1nic"   { 
   name   =   var.nic_name
   location   =   "westurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.myvm1publicip.id 
   } 
 } 

 resource   "azurerm_windows_virtual_machine"   "example"   { 
   name                    =   var.vm_name   
   location                =   "westeurope" 
   resource_group_name     =   azurerm_resource_group.rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvm1nic.id ] 
   size                    =   var.vm_size 
   admin_username          =   "testuser" 
   admin_password          =   random_password.password.result 

   source_image_reference   { 
     publisher   =   "MicrosoftWindowsServer" 
     offer       =   "WindowsServer" 
     sku         =   "2019-Datacenter" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 } 
