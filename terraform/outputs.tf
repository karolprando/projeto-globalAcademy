output "vcn_dmz_id" {
  description = "OCID da VCN-DMZ"
  value       = module.networking.vcn_dmz_id
}

output "vcn_app_id" {
  description = "OCID da VCN-APP"
  value       = module.networking.vcn_app_id
}