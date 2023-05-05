variable "ec2_image_builder_role" {
  type = string
}

variable "policy_description" {
  type = string

  validation {
    condition     = length(var.policy_description) > 4
    error_message = "The policy_description value must contain more than 4 characters."
  }
}

variable "assume_role_policy" {}

variable "policy" {}
