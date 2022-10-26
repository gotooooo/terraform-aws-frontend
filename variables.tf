variable "prefix" {
  type        = string
}
variable "root_domain" {
  type = string
}
variable "subdomain" {
  type = string
}
variable "logs_bucket_name" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}
variable "add_dummy_page" {
  type = bool
}
variable "basic_auth" {
  type = object({
    enabled : bool
    user : string
    pass : string
  })
  default = {
    enabled = false
    user    = "user"
    pass    = "pass"
  }
}
variable "ip_address_blocking" {
  type = object({
    enabled : bool
    allowed_ip_addresses : set(string)
  })
  default = {
    enabled              = true
    allowed_ip_addresses = []
  }
}
