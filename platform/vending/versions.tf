terraform {
  required_version = ">= 1.12.0, < 2.0.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}

locals {
  request = jsondecode(file(var.request_file))
}

provider "azapi" {
  subscription_id  = local.request.subscription_id
  enable_preflight = true
}

provider "azurerm" {
  subscription_id = local.request.subscription_id
  features {}
}
