# AWS IAM Access Key Rotation with Terragrunt

 Terragrunt solution for rotating AWS IAM access keys with zero downtime using a dual-key approach. 
## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step-by-Step Usage](#step-by-step-usage)
- [Configuration](#configuration)
- [Key Rotation Process](#key-rotation-process)
- [Troubleshooting](#troubleshooting)

## Overview

This solution provides:

- **Zero-downtime key rotation**: Seamless transition between keys
- **Multi-environment support**: Separate configs for dev/prod
- **Dynamic configuration**: Works with any AWS account without code changes
- **State management**: Remote state with S3 and DynamoDB locking


## Architecture

```
.
├── README.md                           # This file
├── terragrunt.hcl                      # Root configuration (shared settings)
├── modules/                            # Reusable Terraform modules
│   └── iam-key-rotation/               # Key rotation module
│       ├── main.tf                     # Resource definitions
│       ├── variables.tf                # Input variables
│       └── outputs.tf                  # Output values
└── environments/                       # Environment-specific configs
    ├── dev/                            # Development environment
    │   └── terragrunt.hcl
    ├── staging/                       # Staging environment
    │   └── terragrunt.hcl
    └── prod/                          # Production environment
        └── terragrunt.hcl
```

## Prerequisites

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   # macOS
   brew install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Terragrunt** (>= 0.48)
   ```bash
   # macOS
   brew install terragrunt

   # Linux
   wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.48.0/terragrunt_linux_amd64
   chmod +x terragrunt_linux_amd64
   sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
   ```

3. **AWS CLI** (>= 2.0)
   ```bash
   # macOS
   brew install awscli

   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

### AWS Prerequisites

1. **IAM User**: Create or identify the IAM user whose keys you want to rotate
2. **S3 Bucket**: For Terraform state storage (or use local state)
3. **DynamoDB Table**: For state locking (or use local state)
4. **AWS Credentials**: Configure with appropriate permissions

## Quick Start

### Step 1: Clone and Configure

```bash
# Navigate to the project
cd key-rotation-aws

# Configure AWS credentials
export AWS_PROFILE=your-profile-name
# OR
aws configure
```

### Step 2: Configure Remote State (Optional but Recommended)

Choose one of the following options:

#### Option A: Use Remote State (Recommended for Teams)

1. Create S3 bucket and DynamoDB table:
   ```bash
   # Create S3 bucket
   aws s3 mb s3://my-terraform-state-bucket --region us-east-1

   # Enable versioning
   aws s3api put-bucket-versioning \
     --bucket my-terraform-state-bucket \
     --versioning-configuration Status=Enabled

   # Create DynamoDB table
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region us-east-1
   ```

2. Set environment variables:
   ```bash
   export TF_STATE_BUCKET="my-terraform-state-bucket"
   export TF_STATE_LOCK_TABLE="terraform-state-lock"
   export AWS_REGION="us-east-1"
   ```

#### Option B: Use Local State (Quick Testing)

Comment out the `remote_state` block in `terragrunt.hcl`:

```hcl
# remote_state {
#   backend = "s3"
#   ...
# }
```

### Step 3: Customize for Your Environment

Edit the environment-specific configuration:

```bash
# For development
nano environments/dev/terragrunt.hcl
```

**Required changes:**
- `iam_username`: Change to your actual IAM username
- `aws_region`: Set your preferred AWS region
- Update tags as needed

### Step 4: Initialize and Deploy

```bash
# Navigate to your environment
cd environments/dev

# Initialize Terragrunt
terragrunt init

# Review the plan
terragrunt plan

# Apply changes
terragrunt apply
```

### Step 5: Retrieve Access Keys

```bash
# Get the new access key ID
terragrunt output key1_id

# Get the secret (sensitive)
terragrunt output -raw key1_secret
```

## Step-by-Step Usage

### Scenario 1: Initial Setup (Create First Key)

**Goal**: Create the initial access key for an IAM user.

1. Configure the environment file:
   ```hcl
   # environments/dev/terragrunt.hcl
   inputs = {
     iam_username = "your-iam-username"
     key1_enabled = true   # Create key1
     key2_enabled = false  # Don't create key2
   }
   ```

2. Deploy:
   ```bash
   cd environments/dev
   terragrunt apply
   ```

3. Save the credentials:
   ```bash
   echo "AWS_ACCESS_KEY_ID=$(terragrunt output -raw key1_id)" >> ~/.env
   echo "AWS_SECRET_ACCESS_KEY=$(terragrunt output -raw key1_secret)" >> ~/.env
   ```

### Scenario 2: Rotate Keys (Zero Downtime)

**Goal**: Rotate from key1 to key2 without service interruption.

#### Phase 1: Create Overlap (Both Keys Active)

1. Update configuration:
   ```hcl
   # environments/dev/terragrunt.hcl
   inputs = {
     iam_username = "your-iam-username"
     key1_enabled = true   # Keep key1
     key2_enabled = true   # Create key2
   }
   ```

2. Apply:
   ```bash
   terragrunt apply
   ```

3. Get new key2 credentials:
   ```bash
   terragrunt output -raw key2_id
   terragrunt output -raw key2_secret
   ```

4. **Update your applications** to use key2 credentials

5. **Test thoroughly** to ensure key2 works

#### Phase 2: Remove Old Key

1. Once key2 is confirmed working, update configuration:
   ```hcl
   # environments/dev/terragrunt.hcl
   inputs = {
     iam_username = "your-iam-username"
     key1_enabled = false  # Delete key1
     key2_enabled = true   # Keep key2
   }
   ```

2. Apply:
   ```bash
   terragrunt apply
   ```

3. key1 is now deleted; only key2 remains active

### Scenario 3: Rotate Back (key2 → key1)

Use the same process but flip the flags:

**Phase 1**: Set `key1_enabled=true, key2_enabled=true`
**Phase 2**: Set `key1_enabled=true, key2_enabled=false`

## Configuration

### Environment Variables

You can override defaults using environment variables:

```bash
# Remote state bucket
export TF_STATE_BUCKET="my-custom-bucket"

# State lock table
export TF_STATE_LOCK_TABLE="my-lock-table"

# AWS region
export AWS_REGION="us-west-2"
```

### Configuration Files

#### Root Config (`terragrunt.hcl`)

- Defines shared settings across all environments
- Configures remote state backend
- Generates provider configuration

#### Environment Config (`environments/*/terragrunt.hcl`)

- Environment-specific values
- IAM username
- Key rotation flags
- Tags and metadata

### Key Rotation Flags

| Flag | Value | Effect |
|------|-------|--------|
| `key1_enabled` | `true` | Create/keep key1 |
| `key1_enabled` | `false` | Delete key1 |
| `key2_enabled` | `true` | Create/keep key2 |
| `key2_enabled` | `false` | Delete key2 |

### Multi-Account Support

To use across different AWS accounts:

1. **Use AWS Profiles**:
   ```bash
   export AWS_PROFILE=account-dev
   cd environments/dev
   terragrunt apply

   export AWS_PROFILE=account-prod
   cd environments/prod
   terragrunt apply
   ```

2. **Use IAM Role Assumption** (uncomment in generated `provider.tf`):
   ```hcl
   assume_role {
     role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformRole"
   }
   ```

## Key Rotation Process

### Full Rotation Workflow

```
┌─────────────────┐
│  Initial State  │
│  key1: ACTIVE   │
│  key2: NONE     │
└────────┬────────┘
         │
         │ Set key1=true, key2=true
         ▼
┌─────────────────┐
│ Overlap Period  │
│  key1: ACTIVE   │
│  key2: ACTIVE   │
└────────┬────────┘
         │
         │ Update apps to use key2
         │ Test and verify
         │
         │ Set key1=false, key2=true
         ▼
┌─────────────────┐
│   Final State   │
│  key1: NONE     │
│  key2: ACTIVE   │
└─────────────────┘
```

### Best Practices

1. **Never skip the overlap phase**: Always enable both keys during transition
2. **Test thoroughly**: Verify key2 works before deleting key1
3. **Monitor applications**: Watch for authentication errors during rotation
4. **Document changes**: Keep track of which key is active in each environment
5. **Automate rotation**: Set up scheduled rotations (e.g., every 90 days)

### Useful Commands

```bash
# Check Terragrunt version
terragrunt --version

# Validate configuration
terragrunt validate

# Format code
terragrunt fmt

# Show current state
terragrunt show

# List all outputs
terragrunt output

# Destroy all resources
terragrunt destroy

# Force unlock state (if stuck)
terragrunt force-unlock LOCK_ID
```
##  Contributing
Feel free to contribute
**Author:** Pratik Lamsal




