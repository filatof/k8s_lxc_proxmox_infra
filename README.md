# k8s_lxc_proxmox_infra

Инфраструктурный проект для развёртывания кластера Kubernetes на базе LXC-контейнеров в Proxmox VE. Использует **Ansible** для подготовки шаблонов контейнеров и настройки кластера, а также **Terraform** для автоматического развёртывания LXC-контейнеров из шаблона.

---

## 📁 Структура репозитория

```
k8s_lxc_proxmox_infra/
├── ansible.cfg                 # Настройки Ansible
├── inventory/
│   └── inv_lxc.yml             # Инвентори-файл Ansible для Proxmox LXC
├── playbook/                   # Ansible playbooks
│   ├── create_claster_k8s.yml     # Плейбук для настройки Kubernetes-кластера
│   ├── create_lxc_template.yml    # Плейбук создания шаблона LXC-контейнера
│   ├── remove_lxc.yml             # Удаление контейнеров
│   └── tasks/
│       └── create_one_lxc.yml     # Задачи создания одного LXC-контейнера
├── terraform/                 # Terraform-манифесты
│   ├── k8s.tf                    # Главный конфиг Terraform
│   ├── output.tf                # Outputs
│   ├── provider.tf              # Провайдер Proxmox
│   ├── terraform.tfvars         # Переменные (значения)
│   ├── variables.tf             # Определение переменных
│   ├── terraform.tfstate*       # Состояние Terraform (в .gitignore)
```

---

## ⚙️ Требования

- Proxmox VE с включённым API
- Terraform >= 1.3
- Ansible >= 2.10
- Доступ по SSH к Proxmox
- Подготовленный LXC-шаблон Ubuntu (Jammy), поддерживающий systemd

---

## 🚀 Инструкция по запуску

### 1. Подготовка шаблона LXC для Kubernetes

Создаёт LXC-контейнер, устанавливает в него:

- `containerd`, `runc`, `crictl`
- `kubeadm`, `kubelet`, `kubectl`
- Сетевые плагины CNI

Контейнер сохраняется как шаблон LXC в Proxmox.

```bash
cd playbook
ansible-playbook -i ../inventory/inv_lxc.yml create_lxc_template.yml
```

---

### 2. Развёртывание LXC-контейнеров (узлов кластера)

С помощью Terraform разворачиваются необходимые LXC-контейнеры из созданного шаблона.

```bash
cd terraform
terraform init
terraform apply
```

> Пример terraform.tfvars:

```hcl
pm_user     = "root@pam"
pm_password = "your_password"
pm_host     = "proxmox.local"
template    = "local:vztmpl/ubuntu-jammy-modified_arm64.tar.xz"
target_node = "proxmox"
vm_count    = 3
```

---

### 3. Настройка Kubernetes-кластера

Устанавливает кластер Kubernetes на развёрнутых узлах:

- Инициализация master-узла через `kubeadm init`
- Join worker-узлов через `kubeadm join`
- Установка сетевого плагина (например, Calico)
- Конфигурация kubeconfig

```bash
cd playbook
ansible-playbook -i ../inventory/inv_lxc.yml create_claster_k8s.yml
```

---

### 4. Удаление контейнеров (по необходимости)

Удаляет все созданные LXC-контейнеры.

```bash
cd playbook
ansible-playbook -i ../inventory/inv_lxc.yml remove_lxc.yml
```

---

## 📌 Примечания

- Все контейнеры создаются на базе подготовленного шаблона.
- Используется systemd для управления сервисами внутри контейнера.
- Можно доработать плейбуки для установки дополнительных компонентов кластера (Ingress, Helm, мониторинг и пр.)

---

## 📝 Автор

Создан пользователем **fill** в рамках учебного проекта по Kubernetes и автоматизации инфраструктуры.
