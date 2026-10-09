resource "oci_load_balancer_load_balancer" "lb" {
  compartment_id             = var.compartment_ocid
  display_name               = "LB-WEB"
  shape                      = "flexible"
  subnet_ids                 = [var.subnet_id]
  network_security_group_ids = [var.nsg_id]
  is_private                 = false

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_backend_set" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  name             = "BS-APP"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol    = "HTTP"
    port        = 80
    url_path    = "/"
    return_code = 200
  }
}

resource "oci_load_balancer_backend" "app" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  backendset_name  = oci_load_balancer_backend_set.app.name
  ip_address       = each.value
  port             = 80
}

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "HTTP"
  default_backend_set_name = oci_load_balancer_backend_set.app.name
  port                     = 80
  protocol                 = "HTTP"
}
