#!/usr/bin/env python3

import json
import sys

# Укажите путь к вашему файлу terraform.tfstate
tfstate_file_path = '/mnt/c/Users/minia/Documents/Обучение/IaC/ДЗ/Terraform/Репозиторий/otus-terraform/terraform/terraform.tfstate'

def load_tfstate(tfstate_file_path):
    with open(tfstate_file_path, 'r') as tfstate_file:
        return json.load(tfstate_file)

def generate_inventory(tfstate_data):
    output_data = tfstate_data.get('outputs', {})
    
    inventory = {
        "_meta": {
            "hostvars": {}
        },
        "all": {
            "hosts": []
        }
    }

    # Извлекаем данные из outputs
    database_host_fqdn = output_data.get('database_host_fqdn', {}).get('value', [])
    vm_linux_public_ip_address = output_data.get('vm_linux_public_ip_address', {}).get('value', "")
    vm_linux_2_public_ip_address = output_data.get('vm_linux_2_public_ip_address', {}).get('value', "")
    
    # Добавляем хосты базы данных
    inventory["all"]["hosts"].extend(database_host_fqdn)

    # Добавляем виртуальные машины
    if vm_linux_public_ip_address:
        inventory["all"]["hosts"].append(vm_linux_public_ip_address)
    if vm_linux_2_public_ip_address:
        inventory["all"]["hosts"].append(vm_linux_2_public_ip_address)

    # Добавляем переменные для хостов
    for host in inventory["all"]["hosts"]:
        inventory["_meta"]["hostvars"][host] = {
            "db_name": output_data.get('db_name', {}).get('value', ""),
            "db_user": output_data.get('db_user', {}).get('value', ""),
            "db_password": output_data.get('db_password', {}).get('value', "<sensitive>"),
        }

    return inventory

def main():
    try:
        tfstate_data = load_tfstate(tfstate_file_path)
        inventory = generate_inventory(tfstate_data)
        print(json.dumps(inventory, indent=4))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
