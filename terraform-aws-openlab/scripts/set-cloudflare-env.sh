#!/bin/bash
# Cloudflare Environment Variables for Terraform
# Source this file before running terraform: source scripts/set-cloudflare-env.sh

# Read token from ~/.config/cloudflare
if [ -f ~/.config/cloudflare ]; then
    export TF_VAR_cloudflare_api_token=$(cat ~/.config/cloudflare)
    echo "✅ Cloudflare API token loaded from ~/.config/cloudflare"
else
    echo "❌ Error: ~/.config/cloudflare not found"
    echo "Create it with: echo 'your-token-here' > ~/.config/cloudflare"
    return 1
fi

# Set Zone ID for gineesh.com (NOT lab.gineesh.com - that's just a subdomain)
# Get this from: Cloudflare Dashboard → gineesh.com → Zone ID (right sidebar)
export TF_VAR_cloudflare_zone_id="YOUR_ZONE_ID_HERE"

# Check if Zone ID is set
if [ "$TF_VAR_cloudflare_zone_id" = "YOUR_ZONE_ID_HERE" ]; then
    echo "⚠️  Warning: Update Zone ID in this script"
    echo "   Get it from: Cloudflare Dashboard → gineesh.com → Zone ID"
    echo ""
    echo "Or set it directly:"
    echo "   export TF_VAR_cloudflare_zone_id='your-zone-id-here'"
fi

# Show loaded config
echo ""
echo "Loaded Cloudflare configuration:"
echo "  Zone: gineesh.com"
echo "  DNS record: aap.lab.gineesh.com → Jumpserver IP"
echo "  API Token: ${TF_VAR_cloudflare_api_token:0:20}... (truncated)"
echo "  Zone ID: $TF_VAR_cloudflare_zone_id"
echo ""
echo "Ready to run: terraform plan/apply"
