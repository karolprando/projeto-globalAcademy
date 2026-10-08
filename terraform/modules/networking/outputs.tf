output "vcn_dmz_id" {
  description = "OCID da VCN-DMZ"
  value       = oci_core_vcn.vcn_dmz.id
}

output "vcn_app_id" {
  description = "OCID da VCN-APP"
  value       = oci_core_vcn.vcn_app.id
}