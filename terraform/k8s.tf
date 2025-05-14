variable "kube_count" {
  description = "Number of VMs to create"
  default     = 6
}

resource "proxmox_lxc" "kubernetes" {
  count       = var.kube_count
  target_node  = "pimox2"
  hostname     = format("k8s-node-%02d", 1 + count.index)
  arch = "arm64"
  clone       = "5510"
  full = true
  password     = var.pass_host_lxc
  cores = 4
  memory = 4096
  start = true
  vmid = format("66%02d", count.index+101)

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+O6cXczlSLnL0wZSMe6qRNKpfbdiG6BtYwCmvi5ctR fill@Macmini.local
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local
  EOT

  rootfs {
    storage = "local"
    size    = count.index < 6 ? "20G" : "70G"  # Для первых 3  по 20G , для остальных по 70G
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = format("192.168.1.%d/24", count.index + 101)
    gw     = "192.168.1.1"
    type   = "veth"
  }
}