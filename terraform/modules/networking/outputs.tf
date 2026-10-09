output "vcn_dmz_id" {
  description = "OCID da VCN-DMZ"
  value       = oci_core_vcn.vcn_dmz.id
}

output "vcn_app_id" {
  description = "OCID da VCN-APP"
  value       = oci_core_vcn.vcn_app.id
}

output "subnet_dmz_public_id" {
  description = "OCID da sub-rede publica da VCN-DMZ"
  value       = oci_core_subnet.subnet_dmz_public.id
}

output "subnet_app_01_id" {
  description = "OCID da sub-rede privada SUBNET-APP-01"
  value       = oci_core_subnet.subnet_app_01.id
}

output "subnet_app_02_id" {
  description = "OCID da sub-rede privada SUBNET-APP-02"
  value       = oci_core_subnet.subnet_app_02.id
}

output "lpg_dmz_id" {
  description = "OCID do LPG da VCN-DMZ"
  value       = oci_core_local_peering_gateway.lpg_dmz.id
}

output "lpg_app_id" {
  description = "OCID do LPG da VCN-APP"
  value       = oci_core_local_peering_gateway.lpg_app.id
}
