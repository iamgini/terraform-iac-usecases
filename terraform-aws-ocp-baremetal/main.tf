terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # shared_credentials_files = ["$HOME/.aws/credentials"]
  # profile                  = "openlab"
}


# ============================================================
# OCP Cluster Module
# ============================================================
# Two-phase deployment:
#   Phase 1 — infra only (VPC, NLBs, SGs, Route53, NAT GW):
#     terraform apply
#
#   Phase 2 — OCP nodes (after ignition configs are ready):
#     On bastion:
#       openshift-install create ignition-configs --dir ~/clusterconfig
#       cp ~/clusterconfig/bootstrap.ign ~/ignition-files/
#       nohup python3 -m http.server 8080 &
#     On local machine:
#       export TF_VAR_master_ign_b64=$(ssh bastion 'base64 -w0 ~/clusterconfig/master.ign')
#       export TF_VAR_worker_ign_b64=$(ssh bastion 'base64 -w0 ~/clusterconfig/worker.ign')
#       terraform apply -var="deploy_ocp_nodes=true"
# ============================================================
module "ocp" {
  source = "./ocp"
  count  = var.deploy_ocp_nodes ? 1 : 0

  ami      = var.rhcos_ami_id
  key_name = aws_key_pair.ec2loginkey.key_name

  # Networking
  public_subnet_ids      = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]
  private_subnet_ids     = [aws_subnet.openlab_subnet_private1.id, aws_subnet.openlab_subnet_private2.id]
  vpc_security_group_ids = [aws_security_group.ocp_sg.id]

  # Ignition configs
  bootstrap_ign_url = "http://${var.bastion_private_ip}:8080/bootstrap.ign"
  master_ign_b64    = var.master_ign_b64
  worker_ign_b64    = var.worker_ign_b64

  # NLB Target Group ARNs
  tg_api_external_6443_arn  = aws_lb_target_group.ocp_api_6443.arn
  tg_api_external_22623_arn = aws_lb_target_group.ocp_api_22623.arn
  tg_api_internal_6443_arn  = aws_lb_target_group.ocp_api_int_6443.arn
  tg_api_internal_22623_arn = aws_lb_target_group.ocp_api_int_22623.arn
  tg_app_ingress_443_arn    = aws_lb_target_group.ocp_app_ingress_443.arn
  tg_app_ingress_80_arn     = aws_lb_target_group.ocp_app_ingress_80.arn

  # Cluster identity
  cluster_name = var.ocp_cluster_name

  # Instance sizing
  bootstrap_instance_type    = var.ocp_bootstrap_instance_type
  master_instance_type       = var.ocp_master_instance_type
  worker_instance_type       = var.ocp_worker_instance_type
  master_count               = var.ocp_master_count
  worker_count               = var.ocp_worker_count
  master_root_volume_size    = var.ocp_master_volume_size
  worker_root_volume_size    = var.ocp_worker_volume_size
  bootstrap_root_volume_size = var.ocp_bootstrap_volume_size

  # Node name tags
  master_node_names = var.ocp_master_node_names
  worker_node_names = var.ocp_worker_node_names
}
