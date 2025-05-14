variable "vm_count" {
  description = "Number of VMs to create"
  default     = 5
}

resource "proxmox_virtual_environment_vm" "vm" {
  count       = var.vm_count
  name        = format("node-%02d", count.index + 1)
  migrate     = true
  description = "Managed by OpenTofu"
  tags        = ["k8s"]
  on_boot     = true
  vm_id     = format("60%02d", count.index + 1)


  node_name = "pimox2"   

  clone {
    vm_id     = "5510"
    retries   = 2
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 4
    type  = "host"
    numa  = true
  }

  memory {
    dedicated = 4096
  }

  disk {
    size         = "70"
    interface    = "scsi0"
    datastore_id = "local"
    file_format  = "raw"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        #address = "dhcp"
        address = format("192.168.1.%d/24", count.index + 101)
        gateway = "192.168.1.1"
      }
    }
    dns {
      servers = [
        "192.168.1.1",
        "8.8.8.8"
      ]
    }
    user_account {
      username = "fill"
      keys = [
        var.ssh_public_key
      ]
    }
  }
}
