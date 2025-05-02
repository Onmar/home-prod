resource "proxmox_vm_qemu" "srv-services" {
  for_each = local.variables.servers

  vmid             = each.value.vmid
  name             = each.key
  desc             = each.value.description
  target_node      = local.secrets.target_node
  cores            = 4
  memory           = 16 * 1024
  balloon          = 16 * 1024
  boot             = "order=scsi0;ide2"
  scsihw           = "virtio-scsi-single"
  agent            = 1
  vm_state         = "running"
  automatic_reboot = true

  nameserver   = local.variables.nameserver
  searchdomain = local.secrets.domain
  ipconfig0    = "ip=${each.value.ip}/${local.variables.cidr},gw=${local.variables.gateway}"
  ciuser       = local.secrets.ci_user
  cipassword   = local.secrets.ci_password
  sshkeys      = local.secrets.sshkeys

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = local.variables.disk_storage
          size    = "32G"
        }
      }
      scsi1 {
        disk {
          storage = local.variables.disk_storage
          size    = "128G"
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = local.variables.disk_storage
        }
      }
      ide2 {
        cdrom {
          iso = "local:iso/talos-v1.10.0-amd64.iso"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = local.variables.net_bridge
    tag    = local.variables.net_tag
    mtu    = 1500  # ToDo: Change to 1 once bug is fixed in RC9
  }
}
