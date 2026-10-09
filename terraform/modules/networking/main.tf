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

resource "oci_core_route_table" "rt_dmz_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "RT-DMZ"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw_dmz.id
  }
}

resource "oci_core_security_list" "sl_dmz_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "SL-DMZ"

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
  display_name               = "PUBLIC-SUBNET-DMZ"
  cidr_block                 = "10.10.1.0/24"
  dns_label                  = "dmzpublic"
  route_table_id             = oci_core_route_table.rt_dmz_public.id
  security_list_ids          = [oci_core_security_list.sl_dmz_public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_local_peering_gateway" "lpg_dmz" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_dmz.id
  display_name   = "LPG-DMZ"
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

resource "oci_core_route_table" "rt_app_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "RT-APP"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_app.id
  }
}

resource "oci_core_security_list" "sl_app_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "SL-APP"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    source   = "10.20.0.0/16"
    protocol = "all"
  }
}

resource "oci_core_subnet" "subnet_app_01" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_app.id
  display_name               = "PRIVATE-SUBNET-APP"
  cidr_block                 = "10.20.1.0/24"
  dns_label                  = "app01"
  route_table_id             = oci_core_route_table.rt_app_private.id
  security_list_ids          = [oci_core_security_list.sl_app_private.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "subnet_app_02" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn_app.id
  display_name               = "PRIVATE-SUBNET-IRIS"
  cidr_block                 = "10.20.2.0/24"
  dns_label                  = "app02"
  route_table_id             = oci_core_route_table.rt_app_private.id
  security_list_ids          = [oci_core_security_list.sl_app_private.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_local_peering_gateway" "lpg_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_app.id
  display_name   = "LPG-APP"
  peer_id        = oci_core_local_peering_gateway.lpg_dmz.id
}
