# AWS Open Environment - General Setup

*Warning: this is still in-progress and do not use without validating*

## Introduction

Terraform will provision below resources and take note on details.

- 1x VPC with subnets
- Default `region = "ap-southeast-2"` (**Asia Pacific (Sydney)**), change this in `main.tf` if needed.
- A new Security Group will be created as `local_access`
- And other

## How to use this repository

### Step 1. Install Terraform

If you haven't yet, [Download](https://www.terraform.io/downloads.html) and [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) Terraform.

### Step 2. Configure AWS Credential

Refer [AWS CLI Configuration Guide](https://github.com/iamgini/vagrant-iac-usecases#aws-setup) for details.

### Step 3. Create SSH Keys to Access the ec2 instances

If you have existing keys, you can use that; otherwise create new ssh keys.

- ***Warning**: Please remember to not to overwrite the existing ssh key pair files; use a new file name if you want to keep the old keys.*

- If you are using any key files other than `~/.ssh/id_rsa`, then remember to update the same in `variables.tf` as well.

```shell
$ ssh-keygen
```

## Step 4. Clone the Repository and create your Ansible Lab

```shell
$ git clone https://github.com/iamgini/terraform-iac-usecases
$ cd terraform-aws-openlab

## init terraform
$ terraform init

## verify the resource details before apply
$ terraform plan

## Apply configuration - This step will spin up all necessary resources in your AWS Account
$ terraform apply
.
.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.ec2loginkey: Creating...
aws_security_group.ansible_access: Creating...
.
.
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

<todo>
```

### Step 5. Destroy Lab Once you are Done

As we know, we are dealing with FREE tier, remember to destroy the resources once you finish the lab or practicing for that day.

```shell
$ terraform destroy
```

## Appendix

### Use `local-exec` if you have Ansible installed locally

If you are using Linux/Mac machine and ansible is available locally, then you an use below method for executing Terraform provisioner. (Current configuration is to execute ansible playbook  from `ansible-engine` node itself.)

```json
  provisioner "local-exec" {
    command = "ansible-playbook engine-config.yaml"
  }
```