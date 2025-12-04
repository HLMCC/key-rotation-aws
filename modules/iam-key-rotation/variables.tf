# =============================================================================
# INPUT VARIABLES
# Pratik Lamsal (PL) 12-03-25
# =============================================================================
# Define all input parameters for the IAM key rotation module
# =============================================================================

# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# -----------------------------------------------------------------------------

variable "iam_username" {
  description = "IAM username for which to rotate access keys"
  type        = string

  validation {
    condition     = length(var.iam_username) > 0
    error_message = "IAM username cannot be empty."
  }
}

# -----------------------------------------------------------------------------
# KEY CONTROL VARIABLES
# -----------------------------------------------------------------------------

variable "key1_enabled" {
  description = "Enable/disable key1"
  type        = bool
  default     = true
}

variable "key2_enabled" {
  description = "Enable/disable key2 (true = create/keep, false = delete)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}


