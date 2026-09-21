# ================ Cloudflare DNS for AAP All-in-One =========================

resource "cloudflare_record" "aapaio" {
  count   = var.enable_aapaio && var.cloudflare_api_token != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.aapaio_subdomain
  content = one(module.aapaio).aapaio_eip
  type    = "A"
  ttl     = 300
  proxied = false

  comment = "AAP All-in-One node with direct EIP access"
}
