# terraform-aws-frontend

example

```tf
module "front_end" {
  source = "github.com/gotooooo/terraform-aws-frontend"

  providers = {
    aws.virginia = aws.virginia
  }

  prefix              = "prefix"
  root_domain         = "example.com"
  subdomain           = "frontend"
  logs_bucket_name    = "logs_bucket_name"
  acm_certificate_arn = "acm_certificate_arn"
  add_dummy_page      = true
  basic_auth = {
    enabled : true
    user : "user"
    pass : "pass"
  }
  ip_address_blocking = {
    enabled : true
    allowed_ip_addresses = [
      "100.100.100.100/32"
    ]
  }
}
```
