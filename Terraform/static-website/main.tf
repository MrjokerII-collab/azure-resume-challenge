// Creation rsgroup storage account blob and cdn

resource "azurerm_resource_group" "static_website_tf" {
    name     = "tf_cloud_resume"
    location = "West Europe"
}

resource "azurerm_storage_account" "account_website" {
    name                     = var.storage_name
    resource_group_name      = azurerm_resource_group.static_website_tf.name
    location                 = azurerm_resource_group.static_website_tf.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"

    tags = {
        environment = "Test-TF-cloud-resume"
    }
    // Index webpage name
    static_website {
        index_document = "index.html"
    }
}


resource "azurerm_cdn_profile" "cdn_profile" {
    name                = "staticwebresume"
    location            = azurerm_resource_group.static_website_tf.location
    resource_group_name = azurerm_resource_group.static_website_tf.name
    sku                 = "Standard_Microsoft"

    
}

//nom du point de terminaison
resource "azurerm_cdn_endpoint" "cdn_name" {
    name                = "staticwebresume"
    profile_name        = azurerm_cdn_profile.cdn_profile.name
    location            = azurerm_resource_group.static_website_tf.location
    resource_group_name = azurerm_resource_group.static_website_tf.name

    origin {
        name      = "origin-tfcloudresume"
        host_name = azurerm_storage_account.account_website.primary_web_host
    }
    origin_host_header = azurerm_storage_account.account_website.primary_web_host

    is_http_allowed = false

}
