variable "dns_domain" {
  type = string
}

variable "azure_region" {
  type = string
  default = "East US"
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type = string
}

variable "jnet_image" {
  type = string
  default = "jwarwick/jnet:v0.0.2"
}

variable "nginx_image" {
  type = string
  default = "jwarwick/jnet-nginx:v0.0.1"
}
