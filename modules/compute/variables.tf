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

variable "subnet_id" {
  type = string
}

variable "vm_sku" {
  type    = string
  default = "Standard_B2s"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "ssh_public_key" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}