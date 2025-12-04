# =============================================================================
# ROOT TERRAGRUNT CONFIGURATION
# Pratik Lamsal (PL) 12-03-25
# =============================================================================
# This is the root configuration file that defines common settings shared
# across all environments. Child configurations inherit these settings.
# =============================================================================

# -----------------------------------------------------------------------------
# REMOTE STATE CONFIGURATION
# -----------------------------------------------------------------------------


remote_state {
  backend = "s3"

  config = {
    # S3 bucket for storing Terraform state (change to your bucket)
    bucket         = "${get_env("TF_STATE_BUCKET", "mof-nprod-keyrotation-s3-use1-dev-050859468449")}"

    # Organize state files by environment and region
    key            = "${path_relative_to_include()}/terraform.tfstate"

    # AWS region for the S3 bucket
    region         = "${get_env("AWS_REGION", "us-east-1")}"

    # Enable encryption at rest
    encrypt        = true

    # DynamoDB table for state locking (change to your table)
    dynamodb_table = "${get_env("TF_STATE_LOCK_TABLE", "terraform-state-lock-keyrotation")}"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# -----------------------------------------------------------------------------
# PROVIDER CONFIGURATION
# -----------------------------------------------------------------------------
# Generate AWS provider configuration dynamically based on environment
# -----------------------------------------------------------------------------

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region = var.aws_region

  # Uncomment and configure for cross-account access
  # assume_role {
  #   role_arn = var.assume_role_arn
  # }

  default_tags {
    tags = var.common_tags
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
EOF
}

# -----------------------------------------------------------------------------
# TERRAFORM CONFIGURATION
# -----------------------------------------------------------------------------
# Set Terraform version constraints and enable retries for transient errors
# -----------------------------------------------------------------------------

terraform {
  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=10m"
    ]
  }

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}


