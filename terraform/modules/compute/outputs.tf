output "private_ips" {
  description = "IP privado de cada instancia, indexado pelo nome"
  value       = { for nome, vm in oci_core_instance.vm : nome => vm.private_ip }
}

output "public_ips" {
  description = "IP publico de cada instancia, quando atribuido"
  value       = { for nome, vm in oci_core_instance.vm : nome => vm.public_ip }
}