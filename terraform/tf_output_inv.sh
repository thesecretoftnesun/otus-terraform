#!/bin/bash

export ANSIBLE_INVENTORY=./environments/prod/inv
# Проверяем, установлена ли переменная окружения ANSIBLE_INVENTORY
if [ -z "${ANSIBLE_INVENTORY:-}" ]; then
  echo "Error: Environment variable ANSIBLE_INVENTORY is not set or is empty."
  exit 1
fi

# Создаём временный файл для инвентори
inventory_file="../ansible/environments/prod/inv"

# Формируем инвентори
{
  echo "[wp_app]"
  echo "app ansible_host=$(terraform output -raw vm_linux_2_public_ip_address)"
  echo "app2 ansible_host=$(terraform output -raw vm_linux_public_ip_address)"
} > "$inventory_file"

echo "Inventory file created at $inventory_file."

cat "$inventory_file"
# Устанавливаем переменную окружения для Ansible
#export ANSIBLE_INVENTORY=$inventory_file
#echo "Inventory file created at $inventory_file and ANSIBLE_INVENTORY set."