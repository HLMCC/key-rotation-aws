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
	source = "../../modules/iam-key-rotation
	}


# ====================================
# Setup for my values
# ====================================




inputs = {
  # AWS Configuration
  aws_region = "us-east-1"  # Change to your preferred region

  # IAM User Configuration
  iam_username = "dev-service-account"  

  # Key Rotation Control
  # Toggle these flags to rotate keys:
  # - Initial state: key1=true, key2=false (only key1 active)
  # - Overlap phase: key1=true, key2=true (both keys active)
  # - Final state: key1=false, key2=true (only key2 active)
  
  key1_enabled = true   # Set to false to delete key1
  key2_enabled = false  # Set to true to create key2

  # Resource Tags
  common_tags = {
    Environment = "Development-test"
    ManagedBy   = "terragrunt"
    Purpose     = "key-rotation"
    Team        = "Cloud Operations"
	Owner       = "Pratik Lamsal"
  }

  tags = {
    CostCenter = " Data Engineering"
  }
}




