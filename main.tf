locals {
  block_devices = concat(
    var.image_source.volume_id != "" ? [{
      uuid                  = var.image_source.volume_id
      source_type           = "volume"
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = false
    }] : [],
    var.data_volume_id != "" ? [{
      uuid                  = var.data_volume_id
      source_type           = "volume"
      boot_index            = -1
      destination_type      = "volume"
      delete_on_termination = false
    }] : []
  )
  
  cloudinit_templates = concat([
      {
        filename     = "base.cfg"
        content_type = "text/cloud-config"
        content = templatefile(
          "${path.module}/files/user_data.yaml.tpl", 
          {
            hostname = var.name
            install_dependencies = var.install_dependencies
          }
        )
      }
    ],
    [for cloud_init_configuration in var.cloud_init_configurations: {
      filename     = cloud_init_configuration.filename
      content_type = "text/cloud-config"
      content      = cloud_init_configuration.content
    }]
  )
}

data "template_cloudinit_config" "user_data" {
  gzip = false
  base64_encode = false
  dynamic "part" {
    for_each = local.cloudinit_templates
    content {
      filename     = part.value["filename"]
      content_type = part.value["content_type"]
      content      = part.value["content"]
    }
  }
}

resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_id        = var.image_source.image_id != "" ? var.image_source.image_id : null
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  user_data       = data.template_cloudinit_config.user_data.rendered

  network {
    port = var.network_port.id
  }

  # Dynamically attach the CephFS network port if it is provided
  dynamic "network" {
    for_each = var.cephfs_network_port != null ? [var.cephfs_network_port] : []
    content {
      port = network.value.id
    }
  }

  scheduler_hints {
    group = var.server_group.id
  }

  dynamic "block_device" {
    for_each = local.block_devices
    content {
      uuid                  = block_device.value.uuid
      source_type           = block_device.value.source_type
      boot_index            = block_device.value.boot_index
      destination_type      = block_device.value.destination_type
      delete_on_termination = block_device.value.delete_on_termination
    }
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}