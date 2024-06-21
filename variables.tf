variable "name" {
  description = "Name of the vm"
  type        = string
}

variable "network_port" {
  description = "Network port to assign to the node. Should be of type openstack_networking_port_v2"
  type        = any
}

variable "server_group" {
  description = "Server group to assign to the node. Should be of type openstack_compute_servergroup_v2"
  type        = any
}

variable "image_source" {
  description = "Source of the vm's image"
  type = object({
    image_id  = string
    volume_id = string
  })

  validation {
    condition     = (var.image_source.image_id != "" && var.image_source.volume_id == "") || (var.image_source.image_id == "" && var.image_source.volume_id != "")
    error_message = "You must provide either an image_id or a volume_id, but not both."
  }
}

variable "data_volume_id" {
  description = "The ID of the optional data volume."
  type        = string
  default     = ""
}


variable "flavor_id" {
  description = "ID of the VM flavor"
  type        = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used by admins to ssh to the node"
  type        = string
}

variable "install_dependencies" {
  description = "Whether to install all dependencies in cloud-init"
  type        = bool
  default     = true
}

variable "cloud_init_configurations" {
  description = "List of cloud-init configurations to add to the vm"
  type        = list(object({
    filename = string
    content  = string
  }))
  default = []
}

variable "cephfs_network_port" {
  description = "CephFS network port to assign to the node. Should be of type openstack_networking_port_v2 or null if not used."
  type        = any
  default     = null
}