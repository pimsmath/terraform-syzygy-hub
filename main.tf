data "openstack_images_image_v2" "hub" {
  name        = var.image_name
  most_recent = true
}

# ── Floating IP ────────────────────────────────────────────────────────────────

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.floatingip_pool
}

resource "openstack_networking_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_compute_instance_v2.hub.network[0].port
}

# ── Compute instance ───────────────────────────────────────────────────────────

resource "openstack_compute_instance_v2" "hub" {
  name            = var.environment_name
  flavor_name     = var.flavor_name
  key_pair        = var.key_name
  security_groups = [var.security_group_name]
  user_data       = local.cloudconfig

  block_device {
    uuid                  = data.openstack_images_image_v2.hub.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.boot_volume_size_gb
    boot_index            = 0
    delete_on_termination = false
  }

  network {
    name = var.network_name
  }
}

# ── Homedir volume ─────────────────────────────────────────────────────────────

locals {
  homedir_volume_id = length(var.existing_volumes) == 0 ? (
    openstack_blockstorage_volume_v3.homedir[0].id
  ) : var.existing_volumes[0]
}

resource "openstack_blockstorage_volume_v3" "homedir" {
  count = length(var.existing_volumes) == 0 ? 1 : 0
  name  = format("%s-homedir-%02d", var.environment_name, count.index + 1)
  size  = var.vol_homedir_size
}

resource "openstack_compute_volume_attach_v2" "homedir" {
  instance_id = openstack_compute_instance_v2.hub.id
  volume_id   = local.homedir_volume_id
}

# ── Ansible inventory ──────────────────────────────────────────────────────────

resource "ansible_group" "hub" {
  inventory_group_name = "hub"
}

resource "ansible_group" "hub_dev" {
  inventory_group_name = "hub_dev"
}

resource "ansible_group" "jupyter" {
  inventory_group_name = "jupyter"
  children             = ["hub", "hub_dev"]
}

resource "ansible_host" "hub" {
  inventory_hostname = "${var.environment_name}.${var.domain_name}"
  groups             = ["hub", "hub_dev"]

  vars = {
    ansible_user            = var.ansible_user
    ansible_host            = openstack_networking_floatingip_v2.fip.address
    ansible_ssh_common_args = "-C -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    syzygy_homedir_id = "/dev/disk/by-id/virtio-${substr(
      openstack_compute_volume_attach_v2.homedir.volume_id,
      0,
      20,
    )}"
  }
}
