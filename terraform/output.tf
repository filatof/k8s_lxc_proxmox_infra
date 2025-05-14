output "lxc_info" {
  value = {
    for i in range(var.kube_count) :
    format("k8s-node-%02d", i + 1) => proxmox_lxc.kubernetes[i].network[0].ip
  }
}