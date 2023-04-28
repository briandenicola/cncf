variable "namespace" {
  description   = "The namespace for the workload"
  type          = string
  default       = "default"
}

variable "azure_rbac_group_object_id" {
  description = "GUID of the AKS admin Group"
  default     = "15390134-7115-49f3-8375-da9f6f608dce"
}

variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "postgresql_user_name" {
  description = "Azure PostgreSQL User Name"
  type        = string
  default     = "manager"
}

variable "postgresql_database_name" {
  description = "PostgreSQL Database Name"
  type        = string
  default     = "backstagedb"
}