# ================ Cloudflare DNS for AAP All-in-One =========================

# Create DNS A record pointing to AAP All-in-One EIP
resource "cloudflare_record" "aapaio" {
  count   = var.cloudflare_api_token != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "aapaio.lab"
  content = module.aapaio.aapaio_eip
  type    = "A"
  ttl     = 300
  proxied = false  # Must be false for direct access

  comment = "AAP All-in-One node with direct EIP access"
}
