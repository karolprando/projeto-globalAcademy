# ============================================================
# VCN-DMZ
# ============================================================

resource "oci_core_vcn" "vcn_dmz" {
  compartment_id = var.compartment_ocid

  display_name = "VCN-DMZ"
  cidr_block   = "10.10.0.0/16"

  dns_label = "vcndmz"
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