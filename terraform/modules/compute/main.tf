data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "10"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "vm" {
  for_each = var.instances

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.ad_index].name
  display_name        = each.key
  shape               = var.shape

  shape_config {
    ocpus         = each.value.ocpus
    memory_in_gbs = each.value.memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux.images[0].id
    boot_volume_size_in_gbs = each.value.boot_volume_gb
    boot_volume_vpus_per_gb = 10
  }

  create_vnic_details {
    subnet_id        = each.value.subnet_id
    nsg_ids          = [each.value.nsg_id]
    assign_public_ip = false
    hostname_label   = lower(each.key)
  }

  metadata = merge(
    var.ssh_public_key == "" ? {} : { ssh_authorized_keys = var.ssh_public_key },
    each.value.user_data == null ? {} : { user_data = base64encode(each.value.user_data) }
  )

  agent_config {
    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }

  # Evita recriar a VM quando a Oracle publica uma imagem mais nova
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
