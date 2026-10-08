terraform {
  backend "s3" {
    bucket = "BKT-TFState-GA-Karol"
    namespace = "grtmpjwnaeru"
    key    = "tfstate/terraform.tfstate"
    region = "sa-saopaulo-1"

    endpoints = {
      s3 = "https://grtmpjwnaeru.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}