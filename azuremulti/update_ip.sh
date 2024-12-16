#!/bin/bash

# Paths to the inventory files
INVENTORY_DEV="/Users/snehsrivastava/terraform_practice/ansible/inventories/dev"
INVENTORY_STG="/Users/snehsrivastava/terraform_practice/ansible/inventories/stg"
INVENTORY_PRD="/Users/snehsrivastava/terraform_practice/ansible/inventories/prd"

# Terraform output JSON file
TERRAFORM_OUTPUT="terraform_output.json"

# Step 1: Fetch Terraform outputs in JSON format
terraform output -json > "$TERRAFORM_OUTPUT"
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch Terraform outputs. Ensure Terraform has been applied successfully."
  exit 1
fi

echo "Terraform outputs saved to $TERRAFORM_OUTPUT"

# Step 2: Function to update inventory file
generate_inventory() {
  local env="$1"  # Environment (e.g., dev, stg, prd)
  local inventory_file="$2"  # Path to the inventory file

  # Extract the IP addresses from Terraform outputs
  ips=$(jq -r ".${env}_infra_vmpubip.value[]" "$TERRAFORM_OUTPUT")

  # Check if there are any IPs for this environment
  if [ -z "$ips" ]; then
    echo "No IPs found for environment: $env"
    return
  fi

  # Start generating the inventory file content
  echo "[${env}servers]" > "$inventory_file"
  server_index=1
  for ip in $ips; do
    echo "server${server_index} ansible_host=${ip}" >> "$inventory_file"
    server_index=$((server_index + 1))
  done

  # Add group variables
  echo -e "\n[${env}servers:vars]" >> "$inventory_file"
  echo "ansible_user=adminuser" >> "$inventory_file"
  echo "ansible_ssh_private_key_file=/Users/snehsrivastava/terraform_practice/secrets/tf-key" >> "$inventory_file"
  echo "ansible_python_interpreter=/usr/bin/python3" >> "$inventory_file"

  echo "Updated inventory for $env: $inventory_file"
}

# Step 3: Update inventory files for each environment
generate_inventory "dev" "$INVENTORY_DEV"
generate_inventory "stg" "$INVENTORY_STG"
generate_inventory "prd" "$INVENTORY_PRD"

# Cleanup
rm -f "$TERRAFORM_OUTPUT"
echo "Terraform output file removed. All inventory files updated successfully."
