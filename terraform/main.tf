locals {
  app_user_data = file("${path.module}/scripts/app-nginx.sh")
}

module "networking" {
  source = "./modules/networking"

  compartment_ocid     = var.compartment_ocid
  bastion_client_cidrs = var.bastion_client_cidrs
}

module "compute" {
  source = "./modules/compute"

  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid
  shape            = var.shape
  ad_index         = var.ad_index
  ssh_public_key   = var.ssh_public_key

  instances = {
    "SRV-APP-01" = {
      subnet_id      = module.networking.subnet_app_id
      nsg_id         = module.networking.nsg_app_01_id
      ocpus          = 2
      memory_gb      = 2
      boot_volume_gb = 50
      user_data      = local.app_user_data
    }

    "SRV-APP-02" = {
      subnet_id      = module.networking.subnet_app_id
      nsg_id         = module.networking.nsg_app_02_id
      ocpus          = 2
      memory_gb      = 2
      boot_volume_gb = 50
      user_data      = local.app_user_data
    }

    "SRV-IRIS-01" = {
      subnet_id      = module.networking.subnet_iris_id
      nsg_id         = module.networking.nsg_iris_01_id
      ocpus          = 1
      memory_gb      = 2
      boot_volume_gb = 50
    }

    "SRV-IRISCORE-01" = {
      subnet_id      = module.networking.subnet_iris_id
      nsg_id         = module.networking.nsg_iriscore_01_id
      ocpus          = 1
      memory_gb      = 2
      boot_volume_gb = 50
    }

    "SRV-IRISDB-01" = {
      subnet_id      = module.networking.subnet_iris_id
      nsg_id         = module.networking.nsg_irisdb_01_id
      ocpus          = 1
      memory_gb      = 4
      boot_volume_gb = 50
    }
  }
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  compartment_ocid = var.compartment_ocid
  subnet_id        = module.networking.subnet_dmz_public_id
  nsg_id           = module.networking.nsg_lb_id

  backends = {
    "SRV-APP-01" = module.compute.private_ips["SRV-APP-01"]
    "SRV-APP-02" = module.compute.private_ips["SRV-APP-02"]
  }
}
