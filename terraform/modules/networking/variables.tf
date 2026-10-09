variable "compartment_ocid" {
  description = "OCID do compartment onde os recursos de rede serao criados"
  type        = string
}

variable "db_port" {
  description = "Porta do banco do Zabbix (3306 para MySQL, 5432 para PostgreSQL)"
  type        = number
  default     = 3306
}

variable "bastion_client_cidrs" {
  description = "CIDRs autorizados a abrir sessoes no OCI Bastion"
  type        = list(string)
}
