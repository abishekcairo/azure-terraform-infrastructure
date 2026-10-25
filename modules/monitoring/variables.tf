variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vmss_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}