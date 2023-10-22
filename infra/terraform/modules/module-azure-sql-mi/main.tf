# https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/instance-create-terraform?view=azuresql

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.resource_name_root}-rg" # var.resource_group_name
  location = var.location
}

# Create security group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-${var.resource_name_root}-nsg" # "${random_pet.prefix.id}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-${var.resource_name_root}-vnet" # "${random_pet.prefix.id}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.rg.location
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-${var.resource_name_root}-subnet" # "${random_pet.prefix.id}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/27"]

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Associate subnet and the security group
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a route table
resource "azurerm_route_table" "route_table" {
  name                          = "${var.prefix}-${var.resource_name_root}-rt" # "${random_pet.prefix.id}-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false
}

# Associate subnet and the route table
resource "azurerm_subnet_route_table_association" "route_table_association" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

# Create managed instance
resource "azurerm_mssql_managed_instance" "main" {
  name                         = "${var.prefix}-${var.resource_name_root}-mssql" # "${random_pet.prefix.id}-mssql"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  subnet_id                    = azurerm_subnet.subnet.id
  administrator_login          = var.admin_username # "${replace(random_pet.prefix.id, "-", "")}admin"
  administrator_login_password = var.admin_password # random_password.password.result
  license_type                 = var.license_type
  sku_name                     = var.sku_name
  vcores                       = var.vcores
  storage_size_in_gb           = var.storage_size_in_gb
}

resource "azurerm_mssql_managed_database" "test" {
  name                = var.initial_catalog
  managed_instance_id = azurerm_mssql_managed_instance.main.id
}
