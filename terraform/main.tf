module "networking" {
  source = "./modules/networking"

  compartment_ocid = var.compartment_ocid
}