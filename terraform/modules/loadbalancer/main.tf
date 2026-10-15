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

# Certificado de origem criado no Cloudflare

resource "oci_load_balancer_certificate" "origin" {
  load_balancer_id   = oci_load_balancer_load_balancer.lb.id
  certificate_name   = "academy-origin"
  public_certificate = var.origin_certificate
  private_key        = var.origin_private_key
}

resource "oci_load_balancer_backend_set" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  name             = "BS-APP"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 8080
    url_path          = "/health"
    return_code       = 200
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

resource "oci_load_balancer_backend" "app" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  backendset_name  = oci_load_balancer_backend_set.app.name
  ip_address       = each.value
  port             = 8080
}

# HTTP permanece disponível na porta 80
resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "HTTP"
  default_backend_set_name = oci_load_balancer_backend_set.app.name
  port                     = 80
  protocol                 = "HTTP"
}

# HTTPS na porta 443
resource "oci_load_balancer_listener" "https" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "HTTPS"
  default_backend_set_name = oci_load_balancer_backend_set.app.name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.origin.certificate_name
    verify_peer_certificate = false
    protocols               = ["TLSv1.2", "TLSv1.3"]
  }
}
