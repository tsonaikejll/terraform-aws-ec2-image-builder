locals {
  os_files     = ["amazon-cloudwatch-agent-windows.yml"]
  os_files_map = { for idx, os_file in range(length(local.os_files)) : tostring(local.os_files[idx]) => os_file }
  amis = [
    {
      "env": "Linux",
      "platform": "Linux",
      "ami": "ami-0fddf40d3078f7d74",
    },
    {
      "env": "Linux2",
      "platform": "Linux",
      "ami": "ami-05365526a4cc1b584",
    },
    {
      "env": "Linux3",
      "platform": "Linux",
      "ami": "ami-0885dcd359990aae0",
    },
    {
      "env": "Windows",
      "platform": "Windows",
      "ami": "ami-0f914a4d5552f929a",
    }
  ]


  selected_ami = lookup({ for ami in local.amis : ami.env => ami.ami }, terraform.workspace, null)
  selected_platform = lookup({ for platform in local.amis : platform.env => platform.platform }, terraform.workspace, null)
}

# Create the EC2 IAM role to use for the image
module "image_builder_role" {
  source = "./modules/image_builder_iam_role"
  policy_description     = "IAM ec2 instance profile for the Image Builder instances."
  assume_role_policy     = file("assumption-policy.json")
  policy                 = data.aws_iam_policy_document.image_builder.json
  ec2_image_builder_role = "${var.ec2_image_builder_role}_${terraform.workspace}"

}

# # Image Builder Pipleline
resource "aws_imagebuilder_image_pipeline" "image_builder_pipeline" {
  for_each                         = aws_imagebuilder_image_recipe.amazon-recipe
  name                             = trim("${var.image_builder_pipeline_name}-${terraform.workspace}-${each.key}", ".yml")
  status                           = var.image_builder_pipeline_status
  description                      = "Creates an AMI."
  image_recipe_arn                 = aws_imagebuilder_image_recipe.amazon-recipe[each.key].arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.image_builder_infra.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.default_image_distribution.arn


  tags = {
    "Name" = "${var.image_builder_pipeline_name}-pipeline"
  }


  depends_on = [
    aws_imagebuilder_image_recipe.amazon-recipe,
    aws_imagebuilder_infrastructure_configuration.image_builder_infra
  ]
}


# Image Builder image recipe
resource "aws_imagebuilder_image" "imagebuilder_image" {
  for_each                         = aws_imagebuilder_image_recipe.amazon-recipe
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.default_image_distribution.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.amazon-recipe[each.key].arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.image_builder_infra.arn
  depends_on = [
    data.aws_iam_policy_document.image_builder,
    aws_imagebuilder_image_recipe.amazon-recipe,
    aws_imagebuilder_distribution_configuration.default_image_distribution,
    aws_imagebuilder_infrastructure_configuration.image_builder_infra
  ]

}

resource "aws_imagebuilder_image_recipe" "amazon-recipe" {
  for_each = aws_imagebuilder_component.cw_agent
  block_device_mapping {
    device_name = "/dev/xvdb"

    ebs {
      delete_on_termination = true
      volume_size           = var.ebs_root_vol_size
      volume_type           = "gp3"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.cw_agent[each.key].arn
  }
  name = trim("amazon-recipe-${terraform.workspace}-${each.key}", ".yml")
  #  parent_image = "arn:${data.aws_partition.current.partition}:imagebuilder:${data.aws_region.current.name}:aws:image/amazon-2-x86/x.x.x"
  parent_image = local.selected_ami
  version      = var.image_receipe_version


  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_imagebuilder_component.cw_agent
  ]
  tags = {
    Name         = "CIS_Image"
    CreatedFrom = local.selected_ami
  }
}


## Image Builder Infra Security Group
resource "aws_security_group" "image_builder_sg" {
  count       = var.infra_security_group_ids == null ? 1 : 0
  name        = "image_builder_sg"
  description = "SG to support image builder infra"

  vpc_id = var.vpc_id

}


resource "aws_security_group_rule" "egress" {
  count     = var.infra_security_group_ids == null ? 1 : 0
  type      = "egress"
  from_port = -1
  to_port   = -1
  protocol  = -1

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.image_builder_sg[0].id

}



# Image Builder Infra Config
resource "aws_imagebuilder_infrastructure_configuration" "image_builder_infra" {
  description                   = var.image_builder_infra_config_desc
  instance_profile_name         = "${var.ec2_image_builder_role}_${terraform.workspace}"
  instance_types                = var.infra_supported_instance_types
  key_pair                      = var.aws_key_pair_name
  name                          = "${var.image_builder_infra_config_name}_${terraform.workspace}"
  security_group_ids            = var.infra_security_group_ids
  subnet_id                     = var.subnet_id
  terminate_instance_on_failure = true


  logging {
    s3_logs {
      s3_bucket_name = "${var.aws_s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
      s3_key_prefix  = var.infra_logging_s3_key_prefix
    }
  }

  tags = {
    Name = "amazon-${terraform.workspace}-infrastructure"
  }
}



# Image Builder Distribution
resource "aws_imagebuilder_distribution_configuration" "default_image_distribution" {
  name        = "${var.image_builder_distribution_name}_${terraform.workspace}"
  description = "Image Distribution for ${var.image_builder_distribution_name}"

  distribution {

    region = data.aws_region.current.name

    ami_distribution_configuration {
      name       = "${var.ami_distribution_name}-{{ imagebuilder:buildDate }}"
      ami_tags   = var.ami_tags
      kms_key_id = null
      description = "${var.image_builder_distribution_name}_${terraform.workspace}"

      launch_permission {
        organization_arns = var.distribution_organization_arns
      }
    }
  }
}


# Logging S3 Bucket
resource "aws_s3_bucket_logging" "image_builder_logging_s3_bucket" {
  bucket        = "${var.aws_s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  target_bucket = "${var.aws_s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  target_prefix = var.s3_access_logging_prefix

}

# Description : This terraform module creates a KMS Customer Master Key (CMK) and its alias.
resource "aws_kms_key" "image_builder" {
  description              = var.description
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = var.policy
  multi_region             = var.multi_region

}

# Module      : KMS ALIAS
# Description : Provides an alias for a KMS customer master key..
resource "aws_kms_alias" "image_builder" {
  name          = "alias/image_builder_${terraform.workspace}"
  target_key_id = join("", aws_kms_key.image_builder.*.id)
}



# Amazon Cloudwatch agent component
resource "aws_imagebuilder_component" "cw_agent" {
  for_each = local.os_files_map
  name     = trim("amazon-cloudwatch-agent-${terraform.workspace}-${each.value}", ".yml")
  platform = local.selected_platform
  uri        = "s3://${var.aws_s3_component_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/${each.key}"

  version    = "1.0.1"
  kms_key_id = aws_kms_key.image_builder.arn

  depends_on = [
    data.aws_s3_objects.image_builder_s3_component_bucket_objects
  ]

  lifecycle {
    create_before_destroy = true
  }
}