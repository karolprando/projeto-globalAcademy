variable "compartment_ocid" {
  description = "OCID do compartment onde o Load Balancer sera criado"
  type        = string
}

variable "subnet_id" {
  description = "OCID da sub-rede publica onde o Load Balancer ficara"
  type        = string
}

variable "nsg_id" {
  description = "OCID do NSG do Load Balancer"
  type        = string
}

variable "backends" {
  description = "Backends do Load Balancer: nome => IP privado"
  type        = map(string)
}
