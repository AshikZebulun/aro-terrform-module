locals {
  region_map = {
    uks = "uksouth"
    ukw = "ukwest"
  }

  cluster_region = lookup(local.region_map, var.cluster_location)

  cluster_name = "caas-aro-${var.cluster_location}-${var.cluster_environment}-${var.cluster_count}"

  resource_tags = merge(
    var.common_tags,
    {
      cluster_name = local.cluster_name
      environment  = var.cluster_environment
      location     = local.cluster_region
    }
  )

  roles = [
    "Network Contributor",
    "Contributor",
    "User Access Administrator"
  ]

  cluster_domain = coalesce(var.domain, "${local.cluster_name}.com")

  pull_secret = var.pull_secret_path != null && var.pull_secret_path != "" ? file(var.pull_secret_path) : null
}

resource "azurerm_resource_group" "aro-rg" {
  name     = "${local.cluster_name}-rg"
  location = local.cluster_region
  tags = local.resource_tags
}

resource "azurerm_virtual_network" "aro-vnet" {
  name                = "${local.cluster_name}-vnet"
  location            = azurerm_resource_group.aro-rg.location
  resource_group_name = azurerm_resource_group.aro-rg.name
  tags                = azurerm_resource_group.aro-rg.tags
  address_space       = [var.vnet_cidr_block]
}

resource "azurerm_subnet" "aro-master-subnet" {
  name                 = "${local.cluster_name}-master-subnet"
  resource_group_name  = azurerm_resource_group.aro-rg.name
  virtual_network_name = azurerm_virtual_network.aro-vnet.name
  address_prefixes     = [var.master_subnet_cidr_block]
}

resource "azurerm_subnet" "aro-worker-subnet" {
  name                 = "${local.cluster_name}-worker-subnet"
  resource_group_name  = azurerm_resource_group.aro-rg.name
  virtual_network_name = azurerm_virtual_network.aro-vnet.name
  address_prefixes     = [var.worker_subnet_cidr_block]
}

resource "azurerm_network_security_group" "aro-nsg" {
  name                = "${local.cluster_name}-nsg"
  location            = azurerm_resource_group.aro-rg.location
  resource_group_name = azurerm_resource_group.aro-rg.name
  tags                = azurerm_resource_group.aro-rg.tags
}

resource "azurerm_network_security_rule" "aro-nsg-rule-inbound" {
  name                        = "${local.cluster_name}-nsg-rule-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aro-rg.name
  network_security_group_name = azurerm_network_security_group.aro-nsg.name
}

resource "azurerm_network_security_rule" "aro-nsg-rule-outbound" {
  name                        = "${local.cluster_name}-nsg-rule-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aro-rg.name
  network_security_group_name = azurerm_network_security_group.aro-nsg.name
}


resource "azuread_application" "aro-app" {
  display_name = var.spn_display_name
  owners       = var.spn_owners
}

resource "azuread_service_principal" "aro-spn" {
  client_id = azuread_application.aro-app.client_id
  owners    = var.spn_owners
}

resource "azuread_service_principal_password" "aro-spn-pass" {
  service_principal_id = azuread_service_principal.aro-spn.id
}

resource "azurerm_role_assignment" "aro-role-assignment" {
  for_each            = toset(local.roles)
  scope                = azurerm_virtual_network.aro-vnet.id
  role_definition_name = each.value
  principal_id         = azuread_service_principal.aro-spn.object_id
}


resource "azurerm_redhat_openshift_cluster" "aro-cluster" {
  name                = local.cluster_name
  location            = azurerm_resource_group.aro-rg.location
  resource_group_name = azurerm_resource_group.aro-rg.name

  cluster_profile {
    domain  = "${local.cluster_domain}.com"
    version = var.cluster_version
  }

  network_profile {
    pod_cidr     = var.pod_cidr_block
    service_cidr = var.service_cidr_block
  }

  api_server_profile {
    visibility = var.cluster_profile
  }

  ingress_profile {
    visibility = var.cluster_profile
  }

  main_profile {
    vm_size   = var.master_vm_size
    subnet_id = azurerm_subnet.aro-master-subnet.id
  }

  worker_profile {
    vm_size      = var.worker_vm_size
    disk_size_gb = var.worker_disk_size_gb
    node_count   = var.worker_node_count
    subnet_id    = azurerm_subnet.aro-worker-subnet.id
  }

  service_principal {
    client_id     = azuread_application.aro-app.client_id
    client_secret = azuread_service_principal_password.aro-spn-pass.value
  }

  depends_on = [azurerm_role_assignment.aro-role-assignment]
}