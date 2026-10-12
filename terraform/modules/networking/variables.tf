variable "compartment_ocid" {
  description = "OCID do compartment onde os recursos de rede serao criados"
  type        = string
}

variable "db_port" {
  description = "Porta do banco do Zabbix (3306 para MySQL, 5432 para PostgreSQL)"
  type        = number
  default     = 3306
}