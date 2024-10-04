variable "namespace" {
  description   = "The namespace for the workload"
  type          = string
  default       = "default"
}

variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = string
}
