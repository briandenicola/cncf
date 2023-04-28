resource "azurerm_virtual_network" "this" {
  name                = "${local.resource_name}-network"
  address_space       = [ local.vnet_cidr ]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "nodes" {
  name                 = "nodes"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [ local.nodes_subnet_cidir ]
}

resource "azurerm_subnet" "api-server" {
  name                 = "api-server"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [ local.api_subnet_cidir ]
  
  delegation {
    name = "aks-delegation"

    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]  
    }
  }
}

resource "azurerm_subnet" "sql" {
  name                  = "sql"
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_name  = azurerm_virtual_network.this.name
  address_prefixes      = [ local.sql_subnet_cidr ]
  service_endpoints     = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


resource "azurerm_network_security_group" "this" {
  name                = "${local.resource_name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.nodes.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "pods" {
  subnet_id                 = azurerm_subnet.api-server.id
  network_security_group_id = azurerm_network_security_group.this.id
}