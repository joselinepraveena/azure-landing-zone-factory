terraform {
  required_version = ">= 1.12.0, < 2.0.0"

  required_providers {
    alz = {
      source  = "Azure/alz"
      version = "~> 0.21"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
  }

  backend "azurerm" {}
}

provider "azapi" {
  enable_preflight = true
}

provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/alz"
      ref  = "2026.04.2"
    }
  ]
}
