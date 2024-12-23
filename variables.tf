variable "nxos_password" {
  type        = string
  description = "NX-OS password"
  sensitive   = true
  default     = "Cisco123"
}

variable "fortigate_api_user" {
  type        = string
  description = "fortigate_api_user"
  sensitive   = true
  default     = "nowcomm"
}

variable "fortigate_api_key" {
  type        = string
  description = "fortigate_api_key"
  sensitive   = true
}

variable "vpc-pka-vrf-name" {
  type    = string
  default = "VPC-PKA"
}

variable "vpc-pka-interface" {
  type    = string
  default = "eth1/19"
}