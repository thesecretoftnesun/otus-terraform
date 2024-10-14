#!/usr/bin/env python3
import json
import subprocess
import sys

def get_terraform_output():
    try:
        output = subprocess.check_output(["terraform", "output", "-json"], text=True)
        return json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Error running terraform output: {e}", file=sys.stderr)
        sys.exit(1)

def extract_specific_ips(terraform_output):
    host_ips = []
    for key in ["vm_linux_2_public_ip_address", "vm_linux_public_ip_address"]:
        if key in terraform_output and 'value' in terraform_output[key]:
            host_ips.append(terraform_output[key]['value'])
    return host_ips

def main():
    terraform_output = get_terraform_output()
    host_ips = extract_specific_ips(terraform_output)

    inventory = {
        "all": {
            "hosts": host_ips
        }
    }
    print(json.dumps(inventory))

if __name__ == "__main__":
    main()
