variable "tenancy_ocid" {
  description = "OCID da tenancy OCI"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID do usuario OCI utilizado pela API"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint da chave de API OCI"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Caminho do arquivo da chave privada da API OCI"
  type        = string
}

variable "region" {
  description = "Regiao OCI onde os recursos serao criados"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID do compartment onde os recursos serao criados"
  type        = string

  validation {
    condition = can(
      regex("^ocid1\\.(compartment|tenancy)\\.", var.compartment_ocid)
    )

    error_message = "compartment_ocid deve comecar com ocid1.compartment ou ocid1.tenancy."
  }
}

variable "ssh_public_key" {
  description = "Chave publica SSH utilizada nas VMs"
  type        = string
  default     = ""
}

variable "shape" {
  description = "Shape das instancias Compute"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Quantidade de OCPUs das instancias"
  type        = number
  default     = 1
}

variable "memory_gb" {
  description = "Quantidade de memoria em GB das instancias"
  type        = number
  default     = 6
}

variable "ad_index" {
  description = "Indice do Availability Domain utilizado pelas instancias"
  type        = number
  default     = 0
}
