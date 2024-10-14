#!/bin/bash

# Извлекаем IP-адреса из вывода Terraform и сохраняем их в переменные
load_balancer_ip=$(terraform output -raw load_balancer_public_ip)
vm_linux_ip_1=$(terraform output -raw vm_linux_public_ip_address)
vm_linux_ip_2=$(terraform output -raw vm_linux_2_public_ip_address)

# Формируем строку для ANSIBLE_INVENTORY
ANSIBLE_INVENTORY=$(cat <<EOL
{
    "all": {
        "hosts": [
            "$load_balancer_ip",
            "$vm_linux_ip_1",
            "$vm_linux_ip_2"
        ],
        "children": {}
    }
}
EOL
)

# Записываем в файл или выводим на экран
echo "$ANSIBLE_INVENTORY" > ./tfstate-inventory.json
echo "Ansible inventory created in ./tfstate-inventory.json"

# Устанавливаем переменную окружения
export ANSIBLE_INVENTORY_FILE="./tfstate-inventory.json"
echo "ANSIBLE_INVENTORY_FILE is set to $ANSIBLE_INVENTORY_FILE"
