# ============================================================
# Route53 Private Hosted Zone
# ============================================================
# Why Route53 and not Cloudflare for api-int?
#   - api-int must resolve to PRIVATE IPs of the internal NLB
#   - Masters/workers have no public IPs — they cannot reach public DNS targets
#   - Cloudflare is public DNS only — it would resolve to public IPs
#   - Route53 private zone is attached to the VPC — resolves internally
#   - api.* in Cloudflare (public) still points to external NLB for external access
resource "aws_route53_zone" "ocp_private_zone" {
  name    = "${var.ocp_cluster_name}.${var.ocp_base_domain}"
  comment = "Private zone for OCP cluster internal DNS"

  vpc {
    vpc_id = aws_vpc.openlab_vpc.id
  }

  tags = {
    Name = "${var.ocp_cluster_name}.${var.ocp_base_domain}-private"
  }
}

# api-int record — points to INTERNAL NLB (private IP)
# Used by masters and workers to reach the Machine Config Server during bootstrap
resource "aws_route53_record" "ocp_api_int" {
  zone_id = aws_route53_zone.ocp_private_zone.zone_id
  name    = "api-int.${var.ocp_cluster_name}.${var.ocp_base_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.ocp_api_internal.dns_name]
}

# api record in private zone — resolves to internal NLB within VPC
# Overrides the Cloudflare public record for traffic originating inside the VPC
resource "aws_route53_record" "ocp_api_internal" {
  zone_id = aws_route53_zone.ocp_private_zone.zone_id
  name    = "api.${var.ocp_cluster_name}.${var.ocp_base_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.ocp_api_internal.dns_name]
}
