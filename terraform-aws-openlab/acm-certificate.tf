# ================ Cloudflare DNS for AAP (Jumpserver/Nginx LB) =========================

# Create DNS A record pointing to Jumpserver (Nginx LB)
resource "cloudflare_record" "aap_jumpserver" {
  count   = var.cloudflare_api_token != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.aap_subdomain
  content = aws_eip.jumpserver_eip.public_ip
  type    = "A"
  ttl     = 300
  proxied = false  # Must be false - Cloudflare proxy breaks Let's Encrypt

  comment = "AAP access via Jumpserver Nginx LB with Let's Encrypt SSL"
}

# Optional: Create wildcard DNS for different AAP services
resource "cloudflare_record" "aap_wildcard" {
  count   = var.cloudflare_api_token != "" && var.create_wildcard_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.aap_subdomain}"
  content = aws_eip.jumpserver_eip.public_ip
  type    = "A"
  ttl     = 300
  proxied = false

  comment = "Wildcard for AAP subdomains via Jumpserver Nginx LB"
}
