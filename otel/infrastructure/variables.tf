variable "namespace" {
  description   = "The namespace for the workload identity"
  type          = string
  default       = "default"
}

variable "region" {
  description = "The region for Azure resources"
  default     = "southcentralus"
}