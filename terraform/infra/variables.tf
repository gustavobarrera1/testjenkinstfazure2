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

##

variable "client_id" {
  default        = "b24fa600-ff3d-414a-9802-79047c858bce"
}
variable "client_secret" {
  type        = string
}
variable "tenant_id" {
  default        = "8ee9d595-4f94-41e5-a20c-b29b4e64578b"
}
variable "subscription_id" {
  default = "4dc63939-80f6-4f50-bd19-bc605cf2786d"
}