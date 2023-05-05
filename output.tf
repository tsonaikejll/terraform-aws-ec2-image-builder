output "logging_s3_bucket_id" {
  description = "Logging S3 Bucket ID"
  value       = aws_s3_bucket_logging.image_builder_logging_s3_bucket.id
}

output "pipeline_arn" {
  description = "ARN of EC2 Image Builder Pipeline"
  #  value       = aws_imagebuilder_image_pipeline.image_builder_pipeline[each.key].arn
  value = [for arn_ in aws_imagebuilder_image_pipeline.image_builder_pipeline : arn_]
}
