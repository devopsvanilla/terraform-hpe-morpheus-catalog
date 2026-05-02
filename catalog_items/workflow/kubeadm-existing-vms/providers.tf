terraform {
  required_version = ">= 1.11.0"

  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = ">= 1.3.0"
    }
  }
}

provider "hpe" {
  morpheus {
    access_token = var.morpheus_access_token
    url          = var.morpheus_url
  }
}
