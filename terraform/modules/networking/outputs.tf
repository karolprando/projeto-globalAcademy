output "vcn_dmz_id" {
  description = "OCID da VCN-DMZ"
  value       = oci_core_vcn.vcn_dmz.id
}

output "vcn_app_id" {
  description = "OCID da VCN-APP"
  value       = oci_core_vcn.vcn_app.id
}

output "subnet_dmz_public_id" {
  description = "OCID da subnet publica da VCN-DMZ"
  value       = oci_core_subnet.subnet_dmz_public.id
}

output "subnet_app_id" {
  description = "OCID da PRIVATE-SUBNET-APP"
  value       = oci_core_subnet.subnet_app.id
}

output "subnet_iris_id" {
  description = "OCID da PRIVATE-SUBNET-IRIS"
  value       = oci_core_subnet.subnet_iris.id
}

output "subnet_jumpserver_id" {
  description = "OCID da subnet privada do JumpServer"
  value       = oci_core_subnet.subnet_jumpserver.id
}

output "lpg_dmz_id" {
  description = "OCID do LPG da VCN-DMZ"
  value       = oci_core_local_peering_gateway.lpg_dmz.id
}

output "lpg_app_id" {
  description = "OCID do LPG da VCN-APP"
  value       = oci_core_local_peering_gateway.lpg_app.id
}

output "nsg_lb_id" {
  description = "OCID do NSG do Load Balancer"
  value       = oci_core_network_security_group.nsg_lb.id
}

output "nsg_npm_id" {
  description = "OCID do NSG do Nginx Proxy Manager"
  value       = oci_core_network_security_group.nsg_npm.id
}

output "nsg_jumpserver_id" {
  description = "OCID do NSG do JumpServer"
  value       = oci_core_network_security_group.nsg_jumpserver.id
}

output "nsg_app_01_id" {
  description = "OCID do NSG do SRV-APP-01"
  value       = oci_core_network_security_group.nsg_app_01.id
}

output "nsg_app_02_id" {
  description = "OCID do NSG do SRV-APP-02"
  value       = oci_core_network_security_group.nsg_app_02.id
}

output "nsg_iris_01_id" {
  description = "OCID do NSG do SRV-IRIS-01"
  value       = oci_core_network_security_group.nsg_iris_01.id
}

output "nsg_iriscore_01_id" {
  description = "OCID do NSG do SRV-IRISCORE-01"
  value       = oci_core_network_security_group.nsg_iriscore_01.id
}

output "nsg_irisdb_01_id" {
  description = "OCID do NSG do SRV-IRISDB-01"
  value       = oci_core_network_security_group.nsg_irisdb_01.id
}