variable "cluster_location" {
  description = "Azure Region of the Cluster"
  type        = string

  validation {
    condition     = contains(["uks", "ukw"], var.cluster_location)
    error_message = "Azure Region must be either 'uks' which is UK South or 'ukw' which is UK West."
  }
}

variable "cluster_environment" {
  description = "Environment of the Cluster (dev/pre/prod)"
  type        = string

  validation {
    condition     = contains(["dev", "pre", "prod"], var.cluster_environment)
    error_message = "Environment of the Cluster must be 'dev', 'pre' or 'prod'"
  }
}

variable "cluster_count" {
  description = "Count number for the Cluster."
  type        = number
}

variable "common_tags" {
  description = "Tags to apply to all created Resources."
  type        = map(string)
  default = {
    owner = "AZ"
  }
}

variable "vnet_cidr_block" {
  type        = string
  default     = "10.0.0.0/20"
  description = "CIDR range for the Virtual Network"
}

variable "master_subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/23"
  description = "CIDR range for the Control Plane subnet"
}

variable "worker_subnet_cidr_block" {
  type        = string
  default     = "10.0.2.0/23"
  description = "CIDR range for the Data Plane subnet"
}

variable "spn_owners" {
  description = "List of owner user IDs for the Azure AD application"
  type        = list(string)
}

variable "spn_display_name" {
  description = "Display name for the Azure AD application."
  type        = string
}

variable "domain" {
  type        = string
  description = "Domain for the Cluster."
  default     = null
}

variable "pull_secret_path" {
  type        = string
  default     = null
  description = <<EOF
  Pull Secret for the ARO cluster
  Default null
  EOF
}

variable "cluster_version" {
  type        = string
  description = <<EOF
  ARO version
  Default "4.14.16"
  EOF
  default     = "4.14.16"
}

variable "pod_cidr_block" {
  type        = string
  default     = "10.128.0.0/14"
  description = "CIDR Range for Pods within the Cluster Network"
}

variable "service_cidr_block" {
  type        = string
  default     = "172.30.0.0/16"
  description = "CIDR Range for Services within the Cluster Network"
}

variable "cluster_profile" {
  type        = string
  description = <<EOF
  Cluster Visibility - Public or Private
  Default "Public"
  EOF
  default     = "Public"

  validation {
    condition     = contains(["Public", "Private"], var.cluster_profile)
    error_message = "Invalid 'cluster_profile'. Only 'Public' or 'Private' are allowed."
  }
}

variable "master_vm_size" {
  type        = string
  description = "VM size for the Master Nodes."
  default     = "Standard_D8s_v3"

  validation {
    condition     = var.master_vm_size != "" && var.master_vm_size != null
    error_message = "Invalid 'master_vm_size'. Must be not be empty."
  }
}

variable "worker_vm_size" {
  type        = string
  description = "VM size for the Worker Nodes."
  default     = "Standard_D4s_v3"

  validation {
    condition     = var.worker_vm_size != "" && var.worker_vm_size != null
    error_message = "Invalid 'worker_vm_size'. Must be not be empty."
  }
}

variable "worker_disk_size_gb" {
  type        = number
  default     = 128
  description = "Disk Size for the Worker Nodes."

  validation {
    condition     = var.worker_disk_size_gb >= 128
    error_message = "Invalid 'worker_disk_size_gb'. Minimum of 128GB."
  }
}

variable "worker_node_count" {
  type        = number
  default     = 3
  description = "Number of Worker Nodes."

  validation {
    condition     = var.worker_node_count >= 3
    error_message = "Invalid 'worker_node_count'. Minimum of 3."
  }
}