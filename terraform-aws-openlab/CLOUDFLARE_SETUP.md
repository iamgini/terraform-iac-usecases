# Cloudflare DNS Automation Setup

Auto-creates DNS: `aap.lab.gineesh.com` → Jumpserver IP

## Get Credentials

**API Token:**
- https://dash.cloudflare.com/profile/api-tokens
- Create Token → "Edit zone DNS" template
- Permissions: Zone DNS Edit + Zone Read
- Zone: `gineesh.com`

**Zone ID:**
- Dashboard → `gineesh.com` → Right sidebar → Zone ID

## Set Environment Variables

```bash
# Add to ~/.bashrc or export before terraform:
export TF_VAR_cloudflare_api_token=$(cat ~/.config/cloudflare)
export TF_VAR_cloudflare_zone_id="your-zone-id-here"
```

**Alternative:** Set in `terraform.tfvars` (add to `.gitignore`)

## Verify DNS (after terraform apply)

```bash
terraform output cloudflare_dns_status
dig +short aap.lab.gineesh.com
```

## Notes

- **Zone**: `gineesh.com` (NOT `lab.gineesh.com` - that's a subdomain)
- **Cloudflare proxy**: MUST be `false` (Let's Encrypt needs direct access)
- **EIP**: Not preserved - Cloudflare DNS auto-updates to new IP after destroy/apply
