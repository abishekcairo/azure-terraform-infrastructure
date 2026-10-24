variable "subscription_id" {
  type = string
}

variable "project" {
  type    = string
  default = "tfinfra"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "centralindia"
}