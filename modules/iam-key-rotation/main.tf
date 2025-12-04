# =========================================================================
# IAM access key rotation Module
# Pratik Lamsal (PL) 12-01-25

# The module manages AWS IAM access key rotation using a dual key strategy
# =========================================================================


terraform {
	required_version = ">= 1.0"
	
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 5.0"
			
		}
	}
}


# =========================================================================

# Primary key --(key1)
# enabled=true 
# This key is used in regular operation 

# =========================================================================


resource "aws_iam_access_key" "key1" {
	count = var.key1_enabled ? 1: 0 
	user = var.iam_username
	
	lifecycle{
		create_before_destoy = true
	}

}		


resource "aws_iam_access_key" "key2" {
	count = var.key2_enabled ? 1: 0 
	user = var.iam_username
	
	lifecycle{
		create_before_destoy = true
	}

}