variable "compartment_ocid" {
  description = "OCID do compartment onde as instancias serao criadas"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCID da tenancy (usado para listar os Availability Domains)"
  type        = string
}

variable "shape" {
  description = "Shape das instancias"
  type        = string
}

variable "ad_index" {
  description = "Indice do Availability Domain"
  type        = number
}

variable "ssh_public_key" {
  description = "Chave publica SSH das instancias"
  type        = string
}

variable "instances" {
  description = "Instancias a criar, indexadas pelo nome"
  type = map(object({
    subnet_id      = string
    nsg_id         = string
    ocpus          = number
    memory_gb      = number
    boot_volume_gb = number
    user_data      = optional(string)
  }))
}
