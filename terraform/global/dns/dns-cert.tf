provider "aws" {
  region = var.aws_region
}


resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_acm_certificate" "livekit" {
  domain_name               = var.livekit_subdomain
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_acm_certificate" "turn" {
#   domain_name               = var.turn_subdomain
#   validation_method         = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_route53_record" "livekit_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.livekit.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# resource "aws_route53_record" "turn_cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.turn.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }
#   zone_id = aws_route53_zone.main.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60
# }

resource "aws_acm_certificate_validation" "livekit" {
  certificate_arn         = aws_acm_certificate.livekit.arn
  validation_record_fqdns = [for record in aws_route53_record.livekit_cert_validation : record.fqdn]
}

# resource "aws_acm_certificate_validation" "turn" {
#   certificate_arn         = aws_acm_certificate.turn.arn
#   validation_record_fqdns = [for record in aws_route53_record.turn_cert_validation : record.fqdn]
# }

output "route53_nameservers" {
  value = aws_route53_zone.main.name_servers
}
