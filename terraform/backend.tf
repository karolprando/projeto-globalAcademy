terraform {
  backend "oci" {
    bucket    = "BKT-TFState-GA-Karol"
    namespace = "grtmpjwnaeru"
    key       = "tfstate/terraform.tfstate"
    region    = "sa-saopaulo-1"
    auth      = "APIKey"
  }
}