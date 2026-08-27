output "instance_uuid" {
  description = "UUID of the hub compute instance"
  value       = openstack_compute_instance_v2.hub.id
}

output "floating_ip" {
  description = "Floating IP address assigned to the hub"
  value       = openstack_networking_floatingip_v2.fip.address
}

output "homedir_id" {
  description = "virtio device path for the homedir volume"
  value       = "/dev/disk/by-id/virtio-${substr(openstack_compute_volume_attach_v2.homedir.volume_id, 0, 20)}"
}
