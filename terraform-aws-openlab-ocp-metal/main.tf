provider "aws" {
  region = "ap-southeast-2"
  ## if you want to mention the aws credential from different path, enable below line
  # shared_credentials_file = "$HOME/.aws/credentials"
  # profile = "openlab"
  #version                 = ">=2.0"
}


# ============================================================
# OCP Cluster Module
# ============================================================
# Uncomment after:
#   1. Running: openshift-install create ignition-configs --dir ~/clusterconfig
#   2. Starting bastion HTTP server: cd ~/ignition-files && nohup python3 -m http.server 8080 &
#   3. Base64-encoding ignition files:
#        base64 -w0 ~/clusterconfig/master.ign > ~/clusterconfig/master.64
#        base64 -w0 ~/clusterconfig/worker.ign > ~/clusterconfig/worker.64
# ============================================================
module "ocp" {
  source = "./ocp"

  # RHCOS AMI — must match your OCP installer version
  # Get via: openshift-install coreos print-stream-json | python3 -c "
  #   import json,sys; d=json.load(sys.stdin)
  #   print(d['architectures']['x86_64']['images']['aws']['regions']['ap-southeast-2']['image'])"
  ami      = var.rhcos_ami_id
  key_name = aws_key_pair.ec2loginkey.key_name

  # Networking — bootstrap in public subnet, masters/workers in private
  public_subnet_ids      = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]
  private_subnet_ids     = [aws_subnet.openlab_subnet_private1.id, aws_subnet.openlab_subnet_private2.id]
  vpc_security_group_ids = [aws_security_group.ocp_sg.id]

  # Ignition configs
  # bootstrap_ign_url: bastion private IP serving bootstrap.ign on port 8080
  bootstrap_ign_url = "http://${var.bastion_private_ip}:8080/bootstrap.ign"
  master_ign_b64    = file("${path.root}/clusterconfig/master.64")
  worker_ign_b64    = file("${path.root}/clusterconfig/worker.64")

  # NLB Target Group ARNs — pass from root module outputs
  tg_api_external_6443_arn  = aws_lb_target_group.ocp_api_6443.arn
  tg_api_external_22623_arn = aws_lb_target_group.ocp_api_22623.arn
  tg_api_internal_6443_arn  = aws_lb_target_group.ocp_api_int_6443.arn
  tg_api_internal_22623_arn = aws_lb_target_group.ocp_api_int_22623.arn
  tg_app_ingress_443_arn    = aws_lb_target_group.ocp_app_ingress_443.arn
  tg_app_ingress_80_arn     = aws_lb_target_group.ocp_app_ingress_80.arn

  # Cluster identity
  cluster_name = var.ocp_cluster_name

  # Instance sizing — override defaults if needed
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
