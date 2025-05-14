output "vm_info" {
  description = "Names and IP addresses of the created VMs"
  value = {
    for i in range(var.vm_count) :
    format("vm-%02d", i + 1) => proxmox_virtual_environment_vm.vm[i].ipv4_addresses[1]
  }
}

#создаем файл инвентаря для ansible
resource "local_file" "ansible_inventory" {
  filename = "hosts"
  content = join("\n", [
    for i in range(var.vm_count) : format(
      "server%d ansible_host=192.168.1.%d ansible_user=fill ansible_port=22 ansible_private_key_file=/Users/fill/.ssh/id_ed25519",
      i + 101 ,
      i + 101
    )
  ])
}
