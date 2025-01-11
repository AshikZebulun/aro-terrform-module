# aro-terrform-module

# ARO Cluster Terraform Module

This Terraform module provisions an **Azure Red Hat OpenShift (ARO)** cluster in Microsoft Azure. It includes the necessary resources like **Resource Group**, **Virtual Network**, **Subnets**, **Network Security Groups**, and **Red Hat OpenShift Cluster** with proper configurations and tags.

## Requirements

- Terraform 1.0 or later
- Azure Provider (azurerm) 4.14.0 or later
- Azure Active Directory Provider (azuread)

## Module Usage

### Example Configuration

```hcl
module "aro_cluster" {
  source              = "path_to_your_module"
  cluster_location    = "uks"
  cluster_environment = "dev"
  cluster_count       = 1
  vnet_cidr_block     = "10.0.0.0/20"
  master_subnet_cidr_block = "10.0.1.0/23"
  worker_subnet_cidr_block = "10.0.2.0/23"
  spn_display_name    = "aro-service-principal"
  spn_owners          = ["<user_id_1>", "<user_id_2>"]
  domain              = "customdomain.com"
  cluster_version     = "4.14.16"
  cluster_profile     = "Public"
  pull_secret_path    = "./path/to/pull_secret.txt"
}
```

### Inputs


| Name                     | Type     | Description                                              | Default Value         |
|--------------------------|----------|----------------------------------------------------------|-----------------------|
| `cluster_location`        | `string` | Azure Region for the cluster (e.g., `uks` or `ukw`)      | Required              |
| `cluster_environment`     | `string` | Environment for the cluster (e.g., `dev`, `pre`, `prod`) | Required              |
| `cluster_count`           | `number` | Count number for the cluster                             | Required              |
| `vnet_cidr_block`         | `string` | CIDR block for the Virtual Network                       | `10.0.0.0/20`         |
| `master_subnet_cidr_block`| `string` | CIDR block for the master subnet                         | `10.0.1.0/23`         |
| `worker_subnet_cidr_block`| `string` | CIDR block for the worker subnet                         | `10.0.2.0/23`         |
| `spn_owners`              | `list`   | List of owner user IDs for the Azure AD application      | Required              |
| `spn_display_name`        | `string` | Display name for the Azure AD application                | Required              |
| `cluster_version`         | `string` | OpenShift cluster version                                | `4.14.16`             |
| `pod_cidr_block`          | `string` | CIDR block for the cluster pods                          | `10.128.0.0/14`       |
| `service_cidr_block`      | `string` | CIDR block for the cluster services                      | `172.30.0.0/16`       |
| `cluster_profile`         | `string` | Cluster visibility ("Public" or "Private")               | `Public`              |
| `master_vm_size`          | `string` | VM size for master nodes                                 | `Standard_D8s_v3`     |
| `worker_vm_size`          | `string` | VM size for worker nodes                                 | `Standard_D4s_v3`     |
| `worker_disk_size_gb`     | `number` | Disk size for worker nodes                               | `128`                 |
| `worker_node_count`       | `number` | Number of worker nodes                                   | `3`                   |


### Outputs

| Output Name        | Description                                        |
|--------------------|----------------------------------------------------|
| `console_url`      | The URL of the OpenShift Console.                  |
| `api_url`          | The URL of the OpenShift API server.               |
| `api_server_ip`    | The IP addresses of the OpenShift API server.      |
| `ingress_ip`       | The IP addresses of the OpenShift Ingress controller. |
