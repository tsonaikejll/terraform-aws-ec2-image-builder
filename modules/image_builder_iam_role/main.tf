# Create the AWS IAM role. 
resource "aws_iam_role" "this" {
  name = var.ec2_image_builder_role
  path = "/"

  assume_role_policy = var.assume_role_policy
}

# Create AWS IAM instance profile
# Attach the role to the instance profile
resource "aws_iam_instance_profile" "this" {
  name = var.ec2_image_builder_role
  role = aws_iam_role.this.name
}

# Create a policy for the role
resource "aws_iam_policy" "this" {
  name        = var.ec2_image_builder_role
  path        = "/"
  description = var.policy_description
  policy      = var.policy
}

# Attaches the policy to the IAM role
resource "aws_iam_policy_attachment" "this" {
  name       = var.ec2_image_builder_role
  roles      = [aws_iam_role.this.name]
  policy_arn = aws_iam_policy.this.arn
}
