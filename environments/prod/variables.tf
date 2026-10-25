variable "subscription_id" {
  type = string
}

variable "project" {
  type    = string
  default = "tfinfra"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "ssh_public_key" {
  type = string
}

variable "alert_email" {
  type = string
}