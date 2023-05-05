data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_objects" "image_builder_s3_component_bucket_objects" {
  bucket = "${var.aws_s3_component_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}
