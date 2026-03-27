# AWS Open Environment with OCP on bare metal mode

*Warning: this is still in-progress and do not use without validating*

## Find AMI in the region

```shell
$ openshift-install coreos print-stream-json | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
amis = data['architectures']['x86_64']['images']['aws']['regions']
print('ap-southeast-1 AMI:', amis['ap-southeast-1']['image'])
"
```

## How to apply

```shell
# Step 1 — Apply infrastructure first (VPC, NLBs, SGs, Route53)

# Comment out the ocp module block in main.tf, then:
terraform apply -var="deploy_ocp_nodes=false"

# Step 2 — Generate ignition configs on bastion
openshift-install create ignition-configs --dir ~/clusterconfig

# Step 3 — Start HTTP server for bootstrap.ign
cp ~/clusterconfig/bootstrap.ign ~/ignition-files/
cd ~/ignition-files && nohup python3 -m http.server 8080 &

# Step 4 — Export ignition as env vars (keeps secrets out of tfvars)
export TF_VAR_master_ign_b64=$(base64 -w0 ~/clusterconfig/master.ign)
export TF_VAR_worker_ign_b64=$(base64 -w0 ~/clusterconfig/worker.ign)

# Step 5 — Uncomment ocp module in main.tf, then apply again
terraform apply
```


## AWS Components Managed by This IaC

```shell
## Networking — Core VPC

| Resource | Terraform Name | Details |
|---|---|---|
| VPC | `openlab_vpc` | `10.0.0.0/16`, DNS enabled |
| Subnet — Public 1 | `openlab_subnet_public1` | `10.0.0.0/20`, ap-southeast-2a — bastion, bootstrap |
| Subnet — Public 2 | `openlab_subnet_public2` | `10.0.16.0/20`, ap-southeast-2b |
| Subnet — Private 1 | `openlab_subnet_private1` | `10.0.128.0/20`, ap-southeast-2a — masters, workers |
| Subnet — Private 2 | `openlab_subnet_private2` | `10.0.144.0/20`, ap-southeast-2b — masters, workers |
| Internet Gateway | `openlab_igw` | Attached to VPC — public subnet outbound |
| NAT Gateway | `openlab_nat_gw` | In public subnet — private subnet outbound internet |
| EIP (NAT GW) | `nat_gw_eip` | Static public IP for NAT Gateway |

## Networking — Route Tables

| Resource | Terraform Name | Route |
|---|---|---|
| Public Route Table | `openlab_rtb_public` | `0.0.0.0/0 → IGW` |
| Private Route Table 1 | `openlab_rtb_private1` | `0.0.0.0/0 → NAT GW` |
| Private Route Table 2 | `openlab_rtb_private2` | `0.0.0.0/0 → NAT GW` |
| RT Association — Public 1 | `public_assoc_1` | public subnet 1 → public RT |
| RT Association — Public 2 | `public_assoc_2` | public subnet 2 → public RT |
| RT Association — Private 1 | `private_assoc_1` | private subnet 1 → private RT 1 |
| RT Association — Private 2 | `private_assoc_2` | private subnet 2 → private RT 2 |

## Security Groups

| Resource | Terraform Name | Purpose |
|---|---|---|
| Lab/Bastion SG | `local_access` | SSH, HTTP/S, AAP ports (8443–8447), Redis, gRPC, port 8080 for bootstrap.ign |
| OCP Nodes SG | `ocp_sg` | 6443 (API), 22623 (MCS), 443/80, etcd, kubelet, VXLAN, Geneve, NodePorts |

## Load Balancers (NLB)

| Resource | Terraform Name | Scheme | Purpose |
|---|---|---|---|
| External API NLB | `ocp_api_external` | internet-facing | `api.<cluster>.<domain>` |
| Internal API NLB | `ocp_api_internal` | internal | `api-int.<cluster>.<domain>` — private IPs only |
| App Ingress NLB | `ocp_app_ingress` | internet-facing | `*.apps.<cluster>.<domain>` |

## NLB Target Groups

| Resource | Terraform Name | Port | Health Check | Targets |
|---|---|---|---|---|
| External API 6443 | `ocp_api_6443` | 6443 | HTTPS `/readyz` | Bootstrap + Masters |
| External MCS 22623 | `ocp_api_22623` | 22623 | HTTPS `/readyz` | Bootstrap + Masters |
| Internal API 6443 | `ocp_api_int_6443` | 6443 | HTTPS `/readyz` | Bootstrap + Masters |
| Internal MCS 22623 | `ocp_api_int_22623` | 22623 | HTTPS `/readyz` | Bootstrap + Masters |
| Ingress HTTPS | `ocp_app_ingress_443` | 443 | HTTP 1936 `/healthz/ready` | Workers |
| Ingress HTTP | `ocp_app_ingress_80` | 80 | HTTP 1936 `/healthz/ready` | Workers |

## NLB Listeners (6 total)

| Resource | LB | Port |
|---|---|---|
| `ocp_api_external_6443` | External API NLB | 6443 → External TG 6443 |
| `ocp_api_external_22623` | External API NLB | 22623 → External TG 22623 |
| `ocp_api_internal_6443` | Internal API NLB | 6443 → Internal TG 6443 |
| `ocp_api_internal_22623` | Internal API NLB | 22623 → Internal TG 22623 |
| `ocp_app_ingress_443` | Ingress NLB | 443 → Ingress TG 443 |
| `ocp_app_ingress_80` | Ingress NLB | 80 → Ingress TG 80 |

## NLB Target Group Attachments (12 total)

| Nodes | Target Groups |
|---|---|
| Bootstrap | External 6443, External 22623, Internal 6443, Internal 22623 |
| Masters (x3) | External 6443, External 22623, Internal 6443, Internal 22623 |
| Workers (x3) | Ingress 443, Ingress 80 |

## DNS — Route53

| Resource | Terraform Name | Type | Value |
|---|---|---|---|
| Private Hosted Zone | `ocp_private_zone` | Private, VPC-attached | `ocp420.gineesh.com` |
| api-int record | `ocp_api_int` | CNAME | → Internal NLB DNS |
| api record (internal) | `ocp_api_internal` | CNAME | → Internal NLB DNS |

> `*.apps` and public `api` records are in Cloudflare — not managed by this IaC

## VPC Endpoints

| Resource | Terraform Name | Type | Purpose |
|---|---|---|---|
| S3 Gateway Endpoint | `openlab_s3_vpce` | Gateway | Private/public subnet access to S3 without NAT |

## EC2 — Compute (`ocp` module, deployed when `deploy_ocp_nodes=true`)

| Resource | Terraform Name | Count | Subnet | Public IP |
|---|---|---|---|---|
| Bootstrap | `ocp_bootstrap` | 1 | Public subnet | EIP assigned |
| EIP for Bootstrap | `bootstrap_eip` | 1 | — | Static public IP |
| Masters | `ocp_masters` | 3 (variable) | Private subnets (round-robin AZ) | None — NAT GW |
| Workers | `ocp_workers` | 3 (variable) | Private subnets (round-robin AZ) | None — NAT GW |

## EC2 — Key Pair

| Resource | Terraform Name | Details |
|---|---|---|
| SSH Key Pair | `ec2loginkey` | Imported from `~/.ssh/id_rsa.pub` |

---

## Summary Count

| Category | Count |
|---|---|
| VPC + Subnets | 5 |
| IGW + NAT GW + EIPs | 4 |
| Route Tables + Routes + Associations | 10 |
| Security Groups | 2 |
| Load Balancers (NLB) | 3 |
| Target Groups | 6 |
| Listeners | 6 |
| Target Group Attachments | 12 |
| Route53 Zone + Records | 3 |
| VPC Endpoints | 1 |
| EC2 Instances + EIP (ocp module) | 8 |
| Key Pair | 1 |
| **Total** | **61** |

---

## Not Managed by This IaC (manual or out of scope)

| Item | Where |
|---|---|
| `api.*` public DNS | Cloudflare |
| `*.apps.*` public DNS | Cloudflare |
| Bastion EC2 instance | Manual / separate TF |
| OCP installation (`openshift-install`) | Manual on bastion |
| bootstrap.ign HTTP server | Manual on bastion |
| Post-install bootstrap cleanup | Manual (commands in `output.tf`) |
| AAP nodes | `aap` module (separate) |
| S3 bucket for AAP Hub | `aap-s3.tf` (commented out) |
```