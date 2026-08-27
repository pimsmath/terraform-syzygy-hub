terraform {

  # The configuration for this backend will be filled in by terragrunt
  backend "s3" {
  }

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "~> 1.0"
    }
  }
}

provider "openstack" {}
provider "ansible" {}
