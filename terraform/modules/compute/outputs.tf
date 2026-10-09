output "private_ips" {
  description = "IP privado de cada instancia, indexado pelo nome"
  value       = { for nome, vm in oci_core_instance.vm : nome => vm.private_ip }
}
