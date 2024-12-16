# Azure Infrastructure Automation with Terraform and Ansible

## **Overview**
This project demonstrates the integration of **Terraform** and **Ansible** to automate the creation and configuration of infrastructure on **Microsoft Azure**. 

### **Key Features:**
1. **Terraform**:
   - Creates a dynamic infrastructure setup with Virtual Networks, Subnets, Public IPs, and Virtual Machines.
   - Supports multiple environments: Development (dev), Staging (stg), and Production (prd).
2. **Ansible**:
   - Configures the VMs to install and enable **NGINX**.
   - Deploys a sample webpage to the VMs.
3. **Dynamic Inventory Management**:
   - Parses Terraform outputs to dynamically update the Ansible inventory file.

---

## **Project Structure**
```
.
├── ansible
│   ├── inventories
│   │   ├── dev
│   │   ├── prd
│   │   └── stg
│   ├── nginx-role
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   │   └── index.html
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   ├── tests
│   │   │   ├── inventory
│   │   │   └── test.yml
│   │   └── vars
│   │       └── main.yml
│   ├── playbooks
│   │   └── install_nginx.yml
│   └── roles
├── aws infra
│   ├── install.sh
│   ├── jenkins.sh
│   ├── main.tf
│   └── provider.tf
├── azure infra
│   ├── backend.tf
│   ├── infradeploy
│   │   ├── aws infra
│   │   │   ├── install.sh
│   │   │   ├── jenkins.sh
│   │   │   ├── main.tf
│   │   │   └── provider.tf
│   │   ├── azure-pipelines.yml
│   │   └── azureinfra
│   │       ├── backened.tf
│   │       ├── install.sh
│   │       ├── main.tf
│   │       ├── provider.tf
│   │       ├── tf-key
│   │       └── tf-key.pub
│   ├── install.sh
│   ├── main.tf
│   ├── provider.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── azuremulti
│   ├── backend.tf
│   ├── infra
│   │   ├── output.tf
│   │   ├── variable.tf
│   │   └── vm.tf
│   ├── main.tf
│   ├── provider.tf
│   └── update_ip.sh
├── gcp infra

```

---

## **Setup Instructions**

### **1. Clone the Repository**
```bash
git clone <repository_url>
cd <repository>
```

### **2. Configure Terraform**
1. Update the `variables.tf` file with your Azure subscription details.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the configuration to provision resources:
   ```bash
   terraform apply -auto-approve
   ```

### **3. Update Ansible Inventory**
Run the inventory generation script:
```bash
./update_ip.sh
```

### **4. Configure VMs with Ansible**
Run the Ansible playbook to install and configure **NGINX**:
```bash
ansible-playbook -i inventory/dev ansible/nginx-playbook.yml
```

---

## **Outputs**
Terraform will generate public IPs for the VMs in each environment:
```bash
output "dev_infra_vmpubip" {
  value = module.dev_infra.vmpubips
}
output "stg_infra_vmpubip" {
  value = module.stg_infra.vmpubips
}
output "prd_infra_vmpubip" {
  value = module.prd_infra.vmpubips
}
```
The Ansible inventory file is dynamically updated to include these IPs.

---

## **Technologies Used**
- **Terraform**: Infrastructure as Code (IaC) to provision Azure resources.
- **Ansible**: Configuration management and deployment.
- **Azure**: Cloud platform for hosting infrastructure.

---

## **Challenges and Resolutions**
1. **Dynamic Inventory Management**:
   - Automated inventory updates using Terraform outputs and a Python script.
2. **Firewall Rules**:
   - Ensured port 22 (SSH) and port 80 (HTTP) were open in NSGs.
3. **Configuration Consistency**:
   - Used Ansible roles to standardize configurations.

---

## **Contributions**
Feel free to fork this repository, raise issues, and submit pull requests. Contributions are always welcome!

---
