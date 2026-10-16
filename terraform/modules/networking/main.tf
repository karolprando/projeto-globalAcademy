# ============================================================
# VCN-DMZ
# ============================================================

resource "oci_core_vcn" "vcn_dmz" {
  compartment_id = var.compartment_ocid

  display_name = "VCN-DMZ"
  cidr_block   = "10.10.0.0/16"

  dns_label = "vcndmz"
}

resource "oci_core_internet_gateway" "igw_dmz" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "IGW-DMZ"
  enabled        = true
}

resource "oci_core_local_peering_gateway" "lpg_dmz" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "LPG-DMZ"
}

resource "oci_core_route_table" "rt_dmz_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "RT-DMZ-PUBLIC"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw_dmz.id
  }

  route_rules {
    destination       = "10.20.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.lpg_dmz.id
  }
}

resource "oci_core_security_list" "sl_dmz_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "SL-DMZ-PUBLIC"

  egress_security_rules { #Saída da subnet pra internet
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

#====================
# SUB-NETS VCN-DMZ  |
#====================

resource "oci_core_subnet" "subnet_dmz_public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_dmz.id
  display_name               = "SUBNET-DMZ-PUBLIC"
  cidr_block                 = "10.10.1.0/24"
  dns_label                  = "dmzpublic"
  route_table_id             = oci_core_route_table.rt_dmz_public.id
  security_list_ids          = [oci_core_security_list.sl_dmz_public.id]
  prohibit_public_ip_on_vnic = false
}

#=======================
# FIM SUB-NETS VCN-DMZ |
#=======================



# ============================================================
# VCN-APP
# ============================================================

resource "oci_core_vcn" "vcn_app" {
  compartment_id = var.compartment_ocid

  display_name = "VCN-APP"
  cidr_block   = "10.20.0.0/16"

  dns_label = "vcnapp"
}

resource "oci_core_nat_gateway" "nat_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NAT-APP"
}

resource "oci_core_local_peering_gateway" "lpg_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "LPG-APP"
  peer_id        = oci_core_local_peering_gateway.lpg_dmz.id
}

resource "oci_core_route_table" "rt_app_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "RT-APP-PRIVATE"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_app.id
  }

  route_rules {
    destination       = "10.10.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.lpg_app.id
  }
}

# Sem regras de ingress: a entrada nas VMs e controlada pelos NSGs.
resource "oci_core_security_list" "sl_app_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "SL-APP-PRIVATE"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_subnet" "subnet_app" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_app.id
  display_name               = "PRIVATE-SUBNET-APP"
  cidr_block                 = "10.20.1.0/24"
  dns_label                  = "app01"
  route_table_id             = oci_core_route_table.rt_app_private.id
  security_list_ids          = [oci_core_security_list.sl_app_private.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "subnet_iris" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_app.id
  display_name               = "PRIVATE-SUBNET-IRIS"
  cidr_block                 = "10.20.2.0/24"
  dns_label                  = "app02"
  route_table_id             = oci_core_route_table.rt_app_private.id
  security_list_ids          = [oci_core_security_list.sl_app_private.id]
  prohibit_public_ip_on_vnic = true
}

# ============================================================
# SUBNET PRIVADA DO JUMPSERVER
# ============================================================

resource "oci_core_subnet" "subnet_jumpserver" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_app.id
  display_name               = "PRIVATE-SUBNET-JUMPSERVER"
  cidr_block                 = "10.20.3.0/24"
  dns_label                  = "jumpserver"
  route_table_id             = oci_core_route_table.rt_app_private.id
  security_list_ids          = [oci_core_security_list.sl_app_private.id]
  prohibit_public_ip_on_vnic = true
}

moved {
  from = oci_core_subnet.subnet_app_01
  to   = oci_core_subnet.subnet_app
}

moved {
  from = oci_core_subnet.subnet_app_02
  to   = oci_core_subnet.subnet_iris
}



# ============================================================
# NSGs
# ============================================================

resource "oci_core_network_security_group" "nsg_lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "NSG-LB"
}

resource "oci_core_network_security_group" "nsg_app_01" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-APP-01"
}

resource "oci_core_network_security_group" "nsg_app_02" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-APP-02"
}

resource "oci_core_network_security_group" "nsg_iris_01" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-IRIS-01"
}

resource "oci_core_network_security_group" "nsg_iriscore_01" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-IRISCORE-01"
}

resource "oci_core_network_security_group" "nsg_irisdb_01" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-IRISDB-01"
}

# Nginx Proxy Manager na VCN-DMZ
resource "oci_core_network_security_group" "nsg_npm" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "NSG-SRV-NPM-01"
}

# JumpServer na VCN-APP
resource "oci_core_network_security_group" "nsg_jumpserver" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "NSG-SRV-JUMPSERVER-01"
}

# ============================================================
# LOCALS USADOS NAS REGRAS
# ============================================================

locals {
  app_nsg_ids = {
    app_01 = oci_core_network_security_group.nsg_app_01.id
    app_02 = oci_core_network_security_group.nsg_app_02.id
  }
}

# NSGs das VMs IRIS que rodam agente Zabbix
locals {
  iris_agent_nsg_ids = {
    iris_01   = oci_core_network_security_group.nsg_iris_01.id
    irisdb_01 = oci_core_network_security_group.nsg_irisdb_01.id
  }
}

# NSGs das VMs que podem ser administradas pelo JumpServer
locals {
  vm_nsg_ids = {
    app_01      = oci_core_network_security_group.nsg_app_01.id
    app_02      = oci_core_network_security_group.nsg_app_02.id
    iris_01     = oci_core_network_security_group.nsg_iris_01.id
    iriscore_01 = oci_core_network_security_group.nsg_iriscore_01.id
    irisdb_01   = oci_core_network_security_group.nsg_irisdb_01.id
  }
}

# ============================================================
# REGRAS - NSG-SRV-NPM-01
# ============================================================

# Internet -> NPM: HTTP
resource "oci_core_network_security_group_security_rule" "npm_http_from_internet" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP publico para redirecionamento e validacao de certificados"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Internet -> NPM: HTTPS
resource "oci_core_network_security_group_security_rule" "npm_https_from_internet" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTPS publico para o NPM"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# --------/ REGRAS GLOBALSYS -> NPM WEB /--------

# GLOBALSYS (189.50.2.90/32) -> NPM (Via IP publico)
resource "oci_core_network_security_group_security_rule" "npm_web_from_casa" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "186.233.129.51/32"
  source_type               = "CIDR_BLOCK"
  description               = "Liberação de NPM web apenas para rede de casa"

  tcp_options {
    destination_port_range {
      min = 81
      max = 81
    }
  }
}

# GLOBALSYS (189.50.2.90/32) -> NPM (Via IP publico)
resource "oci_core_network_security_group_security_rule" "npm_web_from_globalsys-01" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "189.50.2.90/32"
  source_type               = "CIDR_BLOCK"
  description               = "Liberação de NPM web apenas para rede globalsys"

  tcp_options {
    destination_port_range {
      min = 81
      max = 81
    }
  }
}

# GLOBALSYS (189.50.2.210/32) -> NPM (Via IP publico)
resource "oci_core_network_security_group_security_rule" "npm_web_from_globalsys-02" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "189.50.2.210/32"
  source_type               = "CIDR_BLOCK"
  description               = "Liberação de NPM web apenas para rede globalsys"

  tcp_options {
    destination_port_range {
      min = 81
      max = 81
    }
  }
}

# GLOBALSYS (177.145.42.18/32) -> NPM (Via IP publico)
resource "oci_core_network_security_group_security_rule" "npm_web_from_globalsys-03" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "177.145.42.18/32"
  source_type               = "CIDR_BLOCK"
  description               = "Liberação de NPM web apenas para rede globalsys"

  tcp_options {
    destination_port_range {
      min = 81
      max = 81
    }
  }
}
# --------/ FIM DAS REGRAS GLOBALSYS > NPM WEB /--------


# JUMPSERVER -> NPM via SSH (22)
resource "oci_core_network_security_group_security_rule" "npm_ssh_from_jumpserver" {
  network_security_group_id = oci_core_network_security_group.nsg_npm.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.20.3.72/32"
  source_type               = "CIDR_BLOCK"
  description               = "Liberação de SSH do Jumpserver para o NPM"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

## -- END -- NSG-SRV-NPM-01 -- ##


# ============================================================
# REGRAS - NSG-LB
# ============================================================

# Internet -> Load Balancer: HTTP
resource "oci_core_network_security_group_security_rule" "lb_http_from_internet" {
  network_security_group_id = oci_core_network_security_group.nsg_lb.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP da internet"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Internet -> Load Balancer: HTTPS
resource "oci_core_network_security_group_security_rule" "lb_https_from_internet" {
  network_security_group_id = oci_core_network_security_group.nsg_lb.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTPS da internet"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}


## -- END -- NSG-LB -- ##


# ============================================================
# REGRAS - NSG-SRV-JUMPSERVER-01
# ============================================================

# NPM (DMZ) -> interface web do JumpServer (APP)
resource "oci_core_network_security_group_security_rule" "jumpserver_web_from_npm" {
  network_security_group_id = oci_core_network_security_group.nsg_jumpserver.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.10.1.50/32"
  source_type               = "CIDR_BLOCK"
  description               = "Interface web do JumpServer acessivel pelo NPM"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# NPM (DMZ) -> SSH JumpServer (APP)
resource "oci_core_network_security_group_security_rule" "jumpserver_ssh_from_npm" {
  network_security_group_id = oci_core_network_security_group.nsg_jumpserver.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.10.1.50/32"
  source_type               = "CIDR_BLOCK"
  description               = "SSH do JumpServer acessivel pelo NPM"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

## -- END -- NSG-SRV-JUMPSERVER-01 -- ##


# ============================================================
# REGRAS - NSG-SRV-APP-01 / NSG-SRV-APP-02 (for_each local.app_nsg_ids)
# ============================================================

# Load Balancer -> APPs (Apenas o LB chega no SRV APP)
resource "oci_core_network_security_group_security_rule" "app_http_from_lb" {
  for_each = local.app_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.10.1.0/24"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP e health check vindos do Load Balancer"

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

# Zabbix (IRISCORE) -> agente2 no SRV APPs
resource "oci_core_network_security_group_security_rule" "app_zabbix_agent_from_iriscore" {
  for_each = local.app_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_iriscore_01.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Zabbix agent (10050) vindo do SRV-IRISCORE-01"

  tcp_options {
    destination_port_range {
      min = 10050
      max = 10050
    }
  }
}

# Zabbix (IRISCORE) -> APPs: ICMP Ping
resource "oci_core_network_security_group_security_rule" "ping_from_iriscore" {
  for_each = local.app_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "1"

  source                    = oci_core_network_security_group.nsg_iriscore_01.id
  source_type               = "NETWORK_SECURITY_GROUP"

  description = "ICMP Ping vindo do SRV-IRISCORE-01"

  icmp_options {
    type = 8
    code = 0
  }
}

## -- END -- NSG-SRV-APP-01 / NSG-SRV-APP-02 -- ##


# ============================================================
# REGRAS - NSG-SRV-IRIS-01
# ============================================================

# NPM (DMZ) -> Grafana (IRIS): HTTP
resource "oci_core_network_security_group_security_rule" "iris_http_from_npm" {
  network_security_group_id = oci_core_network_security_group.nsg_iris_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.10.1.50/32"
  source_type               = "CIDR_BLOCK"
  description               = "Acesso a interface do Grafana pelo NPM"

  tcp_options {
    destination_port_range {
      min = 3000
      max = 3000
    }
  }
}

## -- END -- NSG-SRV-IRIS-01 -- ##


# ============================================================
# REGRAS - NSG-SRV-IRIS-01 / NSG-SRV-IRISDB-01 (for_each local.iris_agent_nsg_ids)
# ============================================================

# Zabbix (IRISCORE) -> agentes no IRIS-01 e IRISDB-01
resource "oci_core_network_security_group_security_rule" "iris_zabbix_agent_from_iriscore" {
  for_each = local.iris_agent_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_iriscore_01.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Zabbix agent (10050) vindo do SRV-IRISCORE-01"

  tcp_options {
    destination_port_range {
      min = 10050
      max = 10050
    }
  }
}


## -- END -- NSG-SRV-IRIS-01 / NSG-SRV-IRISDB-01 -- ##


# ============================================================
# REGRAS - NSG-SRV-IRISCORE-01
# ============================================================

# Grafana (IRIS-01) -> Zabbix API/frontend (IRISCORE)
resource "oci_core_network_security_group_security_rule" "iriscore_web_from_iris" {
  for_each = toset(["80", "443"])

  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_iris_01.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Grafana acessando a API do Zabbix"

  tcp_options {
    destination_port_range {
      min = tonumber(each.value)
      max = tonumber(each.value)
    }
  }
}

# NPM (DMZ) -> Apache do Zabbix (IRISCORE): HTTP
resource "oci_core_network_security_group_security_rule" "iriscore_http_from_npm" {
  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.10.1.50/32"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP do NPM para o frontend web do Zabbix"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}


# JumpServer -> interface web do Zabbix
resource "oci_core_network_security_group_security_rule" "zabbix_web_from_jumpserver" {
  for_each = toset(["80", "443"])

  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_jumpserver.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Interface web do Zabbix acessivel pelo JumpServer"

  tcp_options {
    destination_port_range {
      min = tonumber(each.value)
      max = tonumber(each.value)
    }
  }
}

# APPs -> Zabbix server (agente ativo)
resource "oci_core_network_security_group_security_rule" "iriscore_trapper_from_app" {
  for_each = local.app_nsg_ids

  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Zabbix agent ativo (10051) vindo das APPs"

  tcp_options {
    destination_port_range {
      min = 10051
      max = 10051
    }
  }
}

# IRIS-01 e IRISDB-01 -> Zabbix server (agente ativo)
resource "oci_core_network_security_group_security_rule" "iriscore_trapper_from_iris" {
  for_each = local.iris_agent_nsg_ids

  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Zabbix agent ativo (10051) vindo do IRIS-01 e IRISDB-01"

  tcp_options {
    destination_port_range {
      min = 10051
      max = 10051
    }
  }
}

## -- END -- NSG-SRV-IRISCORE-01 -- ##


# ============================================================
# REGRAS - NSG-SRV-IRISDB-01
# ============================================================

# Zabbix (IRISCORE) -> banco (IRISDB).
resource "oci_core_network_security_group_security_rule" "irisdb_from_iriscore" {
  network_security_group_id = oci_core_network_security_group.nsg_irisdb_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_iriscore_01.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Banco do Zabbix acessado pelo SRV-IRISCORE-01"

  tcp_options {
    destination_port_range {
      min = var.db_port
      max = var.db_port
    }
  }
}

## -- END -- NSG-SRV-IRISDB-01 -- ##


# ============================================================
# REGRAS COMPARTILHADAS - SSH do JumpServer em todas as VMs privadas
# (for_each local.vm_nsg_ids: APP-01, APP-02, IRIS-01, IRISCORE-01, IRISDB-01)
# ============================================================

# JumpServer -> SSH das VMs privadas
resource "oci_core_network_security_group_security_rule" "vm_ssh_from_jumpserver" {
  for_each = local.vm_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.nsg_jumpserver.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "SSH administrativo vindo do JumpServer"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}
