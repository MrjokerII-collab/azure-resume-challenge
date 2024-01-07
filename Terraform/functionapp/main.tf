resource "azurerm_resource_group" "rsgroup" {
  name     = "TF-Api-backend"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}



data "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.name_cosmosdb
  resource_group_name = var.rsg_db
}

resource "azurerm_service_plan" "service_plan" {
  name                = "Api-backend"
  resource_group_name = azurerm_resource_group.rsgroup.name
  location            = azurerm_resource_group.rsgroup.location
  os_type             = "Linux"
  sku_name            = "Y1"
}
resource "azurerm_application_insights" "main" {
  name = "appi-tfcloudresume"
  location = azurerm_resource_group.rsgroup.location
  resource_group_name = azurerm_resource_group.rsgroup.name
  application_type = "web"
}



resource "azurerm_key_vault" "key_vault" {
  
  name                        = "kv-cloudresume"
  location                    = azurerm_resource_group.rsgroup.location
  resource_group_name         = azurerm_resource_group.rsgroup.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
/*
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules = ["",]
  }
*/
}


resource "azurerm_linux_function_app" "functionapp" {

  depends_on = [ azurerm_application_insights.main,
  azurerm_service_plan.service_plan, ]
  name                = "TF-functionapp"
  resource_group_name = azurerm_resource_group.rsgroup.name
  location            = azurerm_resource_group.rsgroup.location

  storage_account_name       = var.account_storage.name
  storage_account_access_key = var.account_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"

    }
  cors {
    allowed_origins = [
      var.url_portal,
      var.url_endpoint
    ]
    support_credentials = true
  }
  
  }

  identity{
    type = "SystemAssigned"
  }
  app_settings = {
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
    "KEY_VAULT_NAME"                 = azurerm_key_vault.key_vault.name
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
    }

  zip_deploy_file = var.zip_file
}

data "azuread_service_principal" "sp_functionapp" {
  display_name = azurerm_linux_function_app.functionapp.name
}



resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.sp_functionapp.object_id

  secret_permissions = [
    "Get",
  ]
}
resource "azurerm_key_vault_access_policy" "access_policy_user" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"
  ]

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]
}


resource "azurerm_key_vault_secret" "secretcosmosdb" {
  depends_on = [ azurerm_key_vault_access_policy.access_policy, azurerm_key_vault_access_policy.access_policy_user ]
  name         = var.secret_name
  value        = data.azurerm_cosmosdb_account.cosmosdb.connection_strings[4]
  key_vault_id = azurerm_key_vault.key_vault.id
}


















/*
  config_json = jsonencode({
    "bindings" = [
    {
      "name": "message",
      "type": "table",
      "tableName": "TablesDB",
      "partitionKey": "Visitors",
      "connection": "AzureWebJobsStorage",
      "direction": "out"
    },
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [
        "get",
        "post"
      ]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
    ]
  })
}

resource "azurerm_function_app_connection" "connection" {
  name               = "serviceconnector"
  function_app_id    = azurerm_linux_function_app.functionapp.id
  target_resource_id = "26102f47-1811-4e17-bdac-1eba1fefd1a3"
  authentication {
    type = "systemAssignedIdentity"
  }
}
*/