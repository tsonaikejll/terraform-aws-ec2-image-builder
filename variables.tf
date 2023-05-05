variable "ec2_image_builder_role" {
  type        = string
  description = "The EC2's IAM role name."
}

variable "aws_s3_bucket_prefix" {
  type        = string
  description = "The S3 bucket name that stores the Image Builder component files."

}

variable "aws_s3_component_prefix" {
  type        = string
  description = "The S3 bucket name that stores the Image Builder component files."

}

variable "ebs_root_vol_size" {
  type = number
}

variable "aws_key_pair_name" {
  type = string
}

variable "image_receipe_version" {
  type    = string
  default = "1.0.2"
}

variable "image_builder_pipeline_name" {
  type = string
}

variable "image_builder_pipeline_status" {
  type        = string
  description = "Status of the image pipeline. Valid values are DISABLED and ENABLED"
  default     = "ENABLED"
}

variable "image_builder_infra_config_name" {
  type        = string
  description = "value"
  default     = "image_builder_infra"
}

variable "image_builder_infra_config_desc" {
  type        = string
  description = "value"
  default     = "Infastracture definition to build images"
}

variable "infra_supported_instance_types" {
  type        = list(string)
  description = "Ec2 Instance types which can be used on the image builder infrastructure"
  default     = ["t3.medium"]
}

variable "infra_security_group_ids" {
  type        = list(any)
  description = "List of Security Group Ids to apply the the image builder infra"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VCP ID of the vpc which hosts the image builder pipeline"
}

variable "subnet_id" {
  type = string
}

variable "infra_logging_s3_key_prefix" {
  type        = string
  description = "S3 key prefix for logging"
}

variable "image_builder_distribution_name" {
  type        = string
  description = "Name of the distribution configuration."
}

variable "ami_distribution_name" {
  type        = string
  default     = "image_builder_ami"
  description = "Name to apply to the distributed AMI"
}

variable "ami_tags" {
  type        = map(any)
  description = "created by image builder pipeline"
}

variable "distribution_organization_arns" {
  type        = list(string)
  description = "List of AWS Organization ARNs to assign"
}

variable "s3_access_logging_prefix" {
  type        = string
  description = "Prefix of the s3 access logging bucket"
}

# Module      : KMS KEY
# Description : Provides a KMS customer master key.
variable "deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Duration in days after which the key is deleted after destruction of the resource."
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the kms is enabled or disabled."
}


variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  sensitive   = true
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "alias" {
  type        = string
  default     = ""
  description = "The display name of the alias. The name must start with the word `alias` followed by a forward slash."
}

variable "policy" {
  type        = string
  default     = ""
  sensitive   = true
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  sensitive   = true
}

variable "enable_key_rotation" {
  type        = string
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "multi_region" {
  type        = bool
  default     = true
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

