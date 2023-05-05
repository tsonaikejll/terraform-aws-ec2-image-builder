ec2_image_builder_role      = "image-builder-role"
ebs_root_vol_size           = 10
aws_key_pair_name           = "image-builder-kp"
image_builder_pipeline_name = "image_builder_pipeline"

aws_s3_bucket_prefix = "jll-logging-bucket"

aws_s3_component_prefix = "image-component"

// List of Security Group Ids to apply the the image builder infra
infra_security_group_ids = ["sg-08577bfc5d28a7cca"]

// VCP ID of the vpc which hosts the image builder pipeline
vpc_id = "vpc-0932707c9b7268173"

// Subnet id
subnet_id = "subnet-08d4bfd44e5af1b19"

// S3 key prefix for logging
infra_logging_s3_key_prefix = "image_builder/"

// Name of the distribution configuration.
image_builder_distribution_name = "Image Builder Distribution"

// Name to apply to the distributed AMI
ami_distribution_name = "image_builder_ami"

// Ami Tags created by image builder pipeline
ami_tags = { "description" = "created by image builder pipeline", "description" = "created by image builder pipeline" }

// List of AWS Organization ARNs to assign
distribution_organization_arns = []

// Name of the s3 access logging bucket
s3_access_logging_prefix = "image_builder/"