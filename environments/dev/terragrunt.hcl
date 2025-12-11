# ====================================
# Development env configuration
# Pratik Lamsal (PL) 12-01-25
# ====================================

# Inherit settings from my file

include "root" {
	path = find_in_parent_folders()
	
	}

# ====================================
# Point to IAM module
# ====================================

terraform {
  source = "../../modules/iam-key-rotation"
}

# ====================================
# Setup for my values
# ====================================




inputs = {
  # AWS Configuration
  aws_region = "us-east-1"

  # IAM User Configuration
  iam_username = "testuser1"  

  # Rotation control
  key1_enabled = true
  key2_enabled = true

  common_tags = {
    Environment = "Development-test"
    ManagedBy   = "terragrunt"
    Purpose     = "key-rotation"
    Team        = "Cloud Operations"
    Owner       = "Pratik Lamsal"
  }

  tags = {
    CostCenter = "Data Engineering"
  }
}