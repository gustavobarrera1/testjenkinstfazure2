variable "location" {
  default = "eastus2"
}

variable "resource_group_name" {
  default = "rg-gbarrera"
}

variable "acr_name" {
  default = "acrtfgbarrera"
}

variable "containerapp_name" {
  default = "my-containerapp"
}

variable "client_id" {
  type        = string
}
variable "client_secret" {
  type        = string
}
variable "tenant_id" {
  type        = string
}
variable "subscription_id" {
  type        = string
}