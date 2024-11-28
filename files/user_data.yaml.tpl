#cloud-config
merge_how:
 - name: list
   settings: [append, no_replace]
 - name: dict
   settings: [no_replace, recurse_list]

ssh_pwauth: false
preserve_hostname: false
hostname: ${hostname}
users:
  - default

%{ if length(dns_servers) > 0 ~}
runcmd:
  - |
    sed -i '/^\s*\(ens\|eth\)[0-9]*:/a\
                dhcp4-overrides:\
                  use-dns: false\
                nameservers:\
                  addresses: [${join(",", dns_servers)}]' /etc/netplan/50-cloud-init.yaml
  - netplan apply
%{ endif ~}
