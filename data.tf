data "aws_route53_zone" "domain" {
  name = "${var.root_domain}."
}
