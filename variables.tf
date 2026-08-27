variable "environment_name" {
  description = "Environment name — used as the instance name and hostname prefix"
}

variable "domain_name" {
  description = "Domain name for the ansible inventory hostname"
  default     = "syzygy.ca"
}

variable "image_name" {
  description = "Name of the Glance image to boot from"
  default     = "AlmaLinux-9-x64-2025-08"
}

variable "boot_volume_size_gb" {
  description = "Size of the boot volume in GB"
  type        = number
  default     = 30
}

variable "flavor_name" {
  description = "OpenStack flavor for the instance"
  default     = "cb4-15gb-140"
}

variable "key_name" {
  description = "Name of the OpenStack keypair to inject for SSH access"
  default     = "id-cc-openstack"
}

variable "security_group_name" {
  description = "Security group to assign to the instance"
  default     = "syzygy"
}

variable "network_name" {
  description = "Name of the network to attach the instance to"
  default     = "rpp-oyilmaz-network"
}

variable "floatingip_pool" {
  description = "Pool to allocate a floating IP from"
  default     = "Public-Network"
}

variable "existing_volumes" {
  description = "List of existing volume IDs to attach instead of creating a new homedir volume"
  type        = list(string)
  default     = []
}

variable "vol_homedir_size" {
  description = "Size of the homedir volume in GB (ignored when existing_volumes is set)"
  type        = number
  default     = 100
}

variable "ansible_user" {
  description = "Default SSH user for Ansible"
  default     = "ptty2u"
}

locals {
  cloudconfig = <<-EOF
    #cloud-config
    preserve_hostname: true
    system_info:
      default_user:
        name: ${var.ansible_user}
  EOF
}
