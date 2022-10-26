resource "aws_wafv2_ip_set" "this" {
  provider = aws.virginia

  name               = "ip-set-allowed-list"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_address_blocking.allowed_ip_addresses
}

resource "aws_wafv2_web_acl" "this" {
  provider = aws.virginia

  name  = "cloudfront-waf-ip-filtering"
  scope = "CLOUDFRONT"

  custom_response_body {
    key          = "block-ip"
    content      = "Access denied."
    content_type = "TEXT_PLAIN"
  }

  default_action {
    block {
      custom_response {
        response_code            = 401
        custom_response_body_key = "block-ip"
      }
    }
  }

  rule {
    name     = "allow-if-ip-matched"
    priority = 5

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.this.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "allow-if-ip-matched"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudfront-waf"
    sampled_requests_enabled   = false
  }
}
