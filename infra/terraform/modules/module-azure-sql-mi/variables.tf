variable "prefix" {
  type        = string
  default     = "mi"
  description = "Prefix of the resource name"
}

variable "resource_group_name" {
  type        = string
  description = "The Resource Group name to deploy the SQL server in."
  # default     = "sql-mi-rg"
}

variable "location" {
  type        = string
  description = "Enter the location where you want to deploy the resources"
  default     = "eastus"
}

variable "sku_name" {
  type        = string
  description = "Enter SKU"
  default     = "GP_Gen5"
}

variable "license_type" {
  type        = string
  description = "Enter license type"
  default     = "BasePrice"
}

variable "vcores" {
  type        = number
  description = "Enter number of vCores you want to deploy"
  default     = 8
}

variable "storage_size_in_gb" {
  type        = number
  description = "Enter storage size in GB"
  default     = 32
}

variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL server."
}

variable "admin_password" {
  description = "The administrator password of the SQL server."
  sensitive   = true
}

variable "initial_catalog" {
  description = "The default database in the SQL server."
  sensitive   = true
}

variable "resource_name_root" {
  description = "The root name of the resources."
  sensitive   = true
}