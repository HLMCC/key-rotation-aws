# =========================================================================
# IAM access key rotation Module
# Pratik Lamsal (PL) 12-03-25

# Access keys are created for application in use
# Secrets are marked senstive and won't appear in logs

# =========================================================================



output "key1_id" {
	description = "Access key id for key 1"
	value = var.key1_enabled ? aws_iam_access_key.key1[0].id : null
}

output "key1_secret" {
	decription = "Secret Access key for key 2"
	value = var.key1_enabled ? aws_iam_access_key.key1[0].secret : null	
	sensitive = true
}




output "key2_id" {
	description = "Access key id for key 2"
	value = var.key1_enabled ? aws_iam_access_key.key2[0].id : null
}

output "key2_secret" {
	decription = "Secret Access key for key 2"
	value = var.key1_enabled ? aws_iam_access_key.key1[0].secret : null	
	sensitive = true
}

#================================================================================

# Status outputs

#================================================================================

output "active_keys" {
  description = "List of currently active key IDs"
  value = compact([
    var.key1_enabled ? aws_iam_access_key.key1[0].id : "",
    var.key2_enabled ? aws_iam_access_key.key2[0].id : ""
  ])
}

output "rotation_status" {
  description = "Current rotation status"
  value = var.key1_enabled && var.key2_enabled ? "OVERLAPPING" : (
    var.key1_enabled ? "KEY1_ACTIVE" : (
      var.key2_enabled ? "KEY2_ACTIVE" : "NO_KEYS_ACTIVE"
    )
  )
}

