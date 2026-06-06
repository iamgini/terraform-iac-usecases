# AAP Infrastructure Playbooks

## Setup Nginx Load Balancer

Configures jumpserver as Nginx load balancer for AAP Gateway nodes with Let's Encrypt SSL (fully automated).

### Prerequisites

1. **Terraform applied** - Infrastructure must be running
2. **DNS configured** - Cloudflare auto-updates or manual A record: `aap.lab.gineesh.com` → jumpserver EIP
3. **Inventory generated**:
   ```bash
   terraform output -raw aap_inventory > inventory.ini
   ```

### Usage

**Run the playbook** (one command, fully automated):

```bash
cd playbooks
ansible-playbook -i ../inventory.ini setup-nginx-lb.yml
```

**What happens:**
1. Installs nginx + certbot
2. Configures load balancing to AAP gateways
3. **Automatically obtains Let's Encrypt certificate**
4. Switches to HTTPS
5. Sets up auto-renewal cron

### What it does

1. ✅ Installs nginx and certbot on jumpserver
2. ✅ Configures load balancing to both AAP gateway nodes
3. ✅ Sets up HTTP initially (for Let's Encrypt validation)
4. ✅ Switches to HTTPS after certificate is obtained
5. ✅ Sets up auto-renewal cron job (3 AM daily)
6. ✅ Configures firewall rules

### Access

- **Before SSL**: http://aap.lab.gineesh.com (redirects to AAP gateways)
- **After SSL**: https://aap.lab.gineesh.com (secure, load balanced)

### Testing

```bash
# Check nginx status
ansible lab-lb -i ../inventory.ini -m shell -a "systemctl status nginx"

# Check nginx config
ansible lab-lb -i ../inventory.ini -m shell -a "nginx -t"

# Check SSL certificate
ansible lab-lb -i ../inventory.ini -m shell -a "certbot certificates"

# Test connectivity
curl -k https://aap.lab.gineesh.com
```

### Troubleshooting

**Gateway IPs changed?**
Just re-run the playbook - it reads from inventory automatically.

**Certificate renewal failing?**
Check logs:
```bash
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

**Nginx not starting?**
```bash
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### Architecture

```
Internet → Jumpserver:443 (nginx) → AAP Gateways → AAP Components
           3.24.28.76                10.0.x.x:8446
           (Let's Encrypt SSL)       (Load balanced)
                                     ├─ aap-gw1
                                     └─ aap-gw2
```

### Notes

- Certificate auto-renews via cron (90-day expiry)
- Load balancing: least_conn algorithm
- WebSocket support enabled (for AAP UI)
- Self-signed AAP certs: `proxy_ssl_verify off`
