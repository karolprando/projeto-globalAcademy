output "vcn_dmz_id" {
  description = "OCID da VCN-DMZ"
  value       = module.networking.vcn_dmz_id
}

output "vcn_app_id" {
  description = "OCID da VCN-APP"
  value       = module.networking.vcn_app_id
}

output "lb_public_ip" {
  description = "IP publico do Load Balancer"
  value       = module.loadbalancer.public_ip
}

output "private_ips" {
  description = "IP privado de cada servidor"
  value       = module.compute.private_ips
}

output "bastion_id" {
  description = "OCID do OCI Bastion (usado para criar sessoes)"
  value       = module.networking.bastion_id
}
