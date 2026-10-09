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

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

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

locals {
  app_nsg_ids = {
    app_01 = oci_core_network_security_group.nsg_app_01.id
    app_02 = oci_core_network_security_group.nsg_app_02.id
  }
}

# Internet -> Load Balancer
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

# Load Balancer -> APPs (a VCN-DMZ chega pelo LPG, entao a origem e o CIDR da sub-rede do LB)
resource "oci_core_network_security_group_security_rule" "app_http_from_lb" {
  for_each = local.app_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_subnet.subnet_dmz_public.cidr_block
  source_type               = "CIDR_BLOCK"
  description               = "HTTP e health check vindos do Load Balancer"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Zabbix (IRISCORE) -> agentes nas APPs
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
      min = each.value
      max = each.value
    }
  }
}

# Zabbix (IRISCORE) -> banco (IRISDB). Nenhuma regra libera a APP para o banco.
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

# ============================================================
# OCI Bastion
# ============================================================

resource "oci_bastion_bastion" "bastion" {
  compartment_id               = var.compartment_ocid
  bastion_type                 = "STANDARD"
  name                         = "BASTION-APP"
  target_subnet_id             = oci_core_subnet.subnet_iris.id
  client_cidr_block_allow_list = var.bastion_client_cidrs
  max_session_ttl_in_seconds   = 10800
}

locals {
  bastion_source = "${oci_bastion_bastion.bastion.private_endpoint_ip_address}/32"

  vm_nsg_ids = {
    app_01      = oci_core_network_security_group.nsg_app_01.id
    app_02      = oci_core_network_security_group.nsg_app_02.id
    iris_01     = oci_core_network_security_group.nsg_iris_01.id
    iriscore_01 = oci_core_network_security_group.nsg_iriscore_01.id
    irisdb_01   = oci_core_network_security_group.nsg_irisdb_01.id
  }
}

# Bastion -> SSH em todas as VMs
resource "oci_core_network_security_group_security_rule" "vm_ssh_from_bastion" {
  for_each = local.vm_nsg_ids

  network_security_group_id = each.value
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.bastion_source
  source_type               = "CIDR_BLOCK"
  description               = "SSH vindo do OCI Bastion"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# Bastion -> UI do Grafana (port forwarding)
resource "oci_core_network_security_group_security_rule" "iris_grafana_from_bastion" {
  network_security_group_id = oci_core_network_security_group.nsg_iris_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.bastion_source
  source_type               = "CIDR_BLOCK"
  description               = "UI do Grafana vinda do OCI Bastion"

  tcp_options {
    destination_port_range {
      min = 3000
      max = 3000
    }
  }
}

# Bastion -> UI do Zabbix (port forwarding)
resource "oci_core_network_security_group_security_rule" "iriscore_web_from_bastion" {
  for_each = toset(["80", "443"])

  network_security_group_id = oci_core_network_security_group.nsg_iriscore_01.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = local.bastion_source
  source_type               = "CIDR_BLOCK"
  description               = "UI do Zabbix vinda do OCI Bastion"

  tcp_options {
    destination_port_range {
      min = each.value
      max = each.value
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
