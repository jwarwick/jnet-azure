provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name = var.dns_domain
  value = azurerm_container_group.jnet-cg.ip_address
  type = "A"
  proxied = true
}

resource "cloudflare_record" "www" {
  depends_on = [cloudflare_record.root]
  zone_id = var.cloudflare_zone_id
  name = "www"
  value = var.dns_domain
  type = "CNAME"
  proxied = true
}

provider "azurerm" {
  features {}
}

resource "random_pet" "deploy-prefix" {
}

resource "azurerm_resource_group" "jnet-rg" {
  name     = "jnet-resource-group-${random_pet.deploy-prefix.id}"
  location = var.azure_region
}

resource "random_pet" "storage-suffix" {
  separator = ""
}

resource "azurerm_storage_account" "jnet-storage" {
  name                     = "storage${random_pet.storage-suffix.id}"
  resource_group_name      = azurerm_resource_group.jnet-rg.name
  location                 = azurerm_resource_group.jnet-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "mongo-data" {
  name                 = "mongodb-data"
  storage_account_name = azurerm_storage_account.jnet-storage.name
  quota                = 10
}

resource "azurerm_storage_share" "images" {
  name                 = "image-data"
  storage_account_name = azurerm_storage_account.jnet-storage.name
  quota                = 10
}

resource "azurerm_container_group" "jnet-cg" {
  name = "jnet-containers-${random_pet.deploy-prefix.id}"
  location = azurerm_resource_group.jnet-rg.location
  resource_group_name = azurerm_resource_group.jnet-rg.name
  ip_address_type = "public"
  dns_name_label = "jnet-${random_pet.deploy-prefix.id}"
  os_type = "Linux"

  container {
    name = "mongo"
    image = "mongo:3.6.8"
    commands = ["mongod", "--dbpath=/data/mongoaz"]
    cpu = 1
    memory = 2

    volume {
      name = "mongo-data"
      read_only = false
      mount_path = "/data/mongoaz"
      storage_account_name = azurerm_storage_account.jnet-storage.name
      share_name = azurerm_storage_share.mongo-data.name
      storage_account_key = azurerm_storage_account.jnet-storage.primary_access_key
    }
  }

  container {
    name = "jnet-app"
    image = var.jnet_image
    cpu = 1
    memory = 2

    volume {
      name = "image-data"
      read_only = false
      mount_path = "/netrunner/resources/public/img/cards"
      storage_account_name = azurerm_storage_account.jnet-storage.name
      share_name = azurerm_storage_share.images.name
      storage_account_key = azurerm_storage_account.jnet-storage.primary_access_key
    }
  }

  container {
    name = "nginx"
    image = var.nginx_image
    cpu = 1
    memory = 2

    ports {
      port = 80
      protocol = "TCP"
    }

    volume {
      name = "nginx-image-data"
      read_only = true
      mount_path = "/opt/jinteki/img/cards"
      storage_account_name = azurerm_storage_account.jnet-storage.name
      share_name = azurerm_storage_share.images.name
      storage_account_key = azurerm_storage_account.jnet-storage.primary_access_key
    }
  }
}
