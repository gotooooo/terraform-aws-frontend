resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.this.id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = aws_s3_bucket.this.id
  web_acl_id      = var.ip_address_blocking.enabled ? aws_wafv2_web_acl.this.arn : null

  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${var.logs_bucket_name}.s3.amazonaws.com"
    prefix          = "CFlogs/"
  }

  aliases = tolist([aws_s3_bucket.this.id])

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this.id
    compress         = true

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers",
        "Access-Control-Allow-Origin"
      ]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 86400

    dynamic "function_association" {
      for_each = var.basic_auth.enabled ? [""] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.this.arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_function" "this" {
  name    = "basic-auth"
  runtime = "cloudfront-js-1.0"
  comment = "This function provides basic authentication."
  publish = true
  code = templatefile("${path.module}/functions/basic_auth.js", {
    user : var.basic_auth.user,
    pass : var.basic_auth.pass
  })
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "cloudfront-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
