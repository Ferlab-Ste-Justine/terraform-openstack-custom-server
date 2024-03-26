# About

This module provisions a custom server on OpenStack.

It offers a streamlined process for:
- Instantiating an OpenStack VM with specified flavors and image sources.
- Assigning a network port and server group to the VM.
- Setting up SSH access through specified key pairs.
- Optionally installing dependencies via cloud-init.
- Extending cloud-init with custom configurations for advanced setup.

# Usage

## Input Variables

- **name**: Name to give to the VM. Used for identification within OpenStack.
- **network_port**: Network port to assign to the VM. Should be of type `openstack_networking_port_v2`.
- **cephfs_network_port**: CephFS network port to assign to the node. Should be of type `openstack_networking_port_v2` or null if not used.
- **server_group**: Server group to assign to the VM. Should be of type `openstack_compute_servergroup_v2`.
- **image_source**: Source of the VM's image. Provide either an `image_id` (for image-based VMs) or a `volume_id` (for volume-based VMs), but not both. The object structure is:
  - `image_id`: String ID of the image to use.
  - `volume_id`: String ID of the volume to use.
- **flavor_id**: ID of the VM flavor. Specifies the compute, memory, and storage capacity of the VM.
- **keypair_name**: Name of the keypair used for SSH access to the VM. 
- **install_dependencies**: Boolean flag to determine whether to install all dependencies in cloud-init. Defaults to `true`.
- **cloud_init_configurations**: List of additional cloud-init configurations. Each entry should include:
  - `filename`: A unique and descriptive filename for the cloud-init part.
  - `content`: The content of the cloud-init configuration.

## Example of a Custom Cloud-Init Part

If you want to perform custom operations during the VM setup, like installing additional software, you can use the `cloud_init_configurations` variable. For example, to install and configure cephadm:

```hcl
cloud_init_configurations = [
  {
    filename = "cephadm.cfg"
    content  = <<-EOF
      #cloud-config
      runcmd:
        - apt-get update
        - apt-get install -y cephadm
        - cephadm init
      EOF
  }
]
