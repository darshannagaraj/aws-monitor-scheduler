# AWS Credentials Setup Guide

## Issue: "Unable to locate credentials"

The AWS Monitor Scheduler is failing to invoke Lambda functions because AWS credentials are not configured on the EC2 instance.

## Solution Options

### Option 1: IAM Role (Recommended for EC2)

**This is the most secure and recommended approach for EC2 instances.**

1. **Create an IAM Role:**
   ```bash
   # Go to AWS Console → IAM → Roles → Create Role
   # Select "EC2" as the trusted entity
   # Attach the following policies:
   # - AWSLambda_FullAccess (or create custom policy)
   # - AmazonRDSFullAccess (if accessing RDS)
   ```

2. **Attach the Role to Your EC2 Instance:**
   ```bash
   # In AWS Console → EC2 → Instances → Select your instance
   # Actions → Security → Modify IAM role
   # Select the role you created
   ```

3. **Verify the Role is Attached:**
   ```bash
   # On your EC2 instance, run:
   curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
   ```

### Option 2: AWS CLI Configuration

**For development/testing purposes:**

1. **Install AWS CLI:**
   ```bash
   sudo yum install -y aws-cli
   ```

2. **Configure AWS Credentials:**
   ```bash
   aws configure
   # Enter your:
   # - AWS Access Key ID
   # - AWS Secret Access Key
   # - Default region (e.g., us-east-1)
   # - Default output format (json)
   ```

3. **Verify Configuration:**
   ```bash
   aws sts get-caller-identity
   ```

### Option 3: Environment Variables

**Alternative method using environment variables:**

1. **Set Environment Variables:**
   ```bash
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   export AWS_DEFAULT_REGION=us-east-1
   ```

2. **Add to ~/.bashrc for persistence:**
   ```bash
   echo 'export AWS_ACCESS_KEY_ID=your_access_key' >> ~/.bashrc
   echo 'export AWS_SECRET_ACCESS_KEY=your_secret_key' >> ~/.bashrc
   echo 'export AWS_DEFAULT_REGION=us-east-1' >> ~/.bashrc
   source ~/.bashrc
   ```

## Required IAM Permissions

Your AWS credentials need the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances",
                "rds:DescribeDBClusters"
            ],
            "Resource": "*"
        }
    ]
}
```

## Testing AWS Credentials

After setting up credentials, test them:

```bash
# Test Lambda access
aws lambda list-functions --region us-east-1

# Test RDS access
aws rds describe-db-instances --region us-east-1

# Test overall credentials
aws sts get-caller-identity
```

## Troubleshooting

### Common Issues:

1. **"Unable to locate credentials"**
   - Check if IAM role is attached to EC2 instance
   - Verify AWS CLI configuration: `aws configure list`
   - Check environment variables: `env | grep AWS`

2. **"Access Denied"**
   - Verify IAM permissions are correct
   - Check if the Lambda function exists in the target region
   - Ensure the IAM role/user has the required permissions

3. **"Invalid credentials"**
   - Regenerate AWS access keys
   - Check if credentials are expired
   - Verify the AWS region is correct

## Security Best Practices

1. **Use IAM Roles for EC2** (Recommended)
   - Never store AWS credentials on EC2 instances
   - IAM roles are automatically rotated
   - No need to manage access keys

2. **If using Access Keys:**
   - Use least privilege principle
   - Rotate keys regularly
   - Never commit keys to version control
   - Use AWS Secrets Manager for production

## Quick Fix Script

Run this script to check and fix common credential issues:

```bash
#!/bin/bash
echo "🔍 Checking AWS credentials..."

# Check if IAM role is available
if curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null; then
    echo "✅ IAM role detected"
else
    echo "⚠️  No IAM role found"
fi

# Check AWS CLI configuration
if aws configure list | grep -q "access_key"; then
    echo "✅ AWS CLI configured"
else
    echo "⚠️  AWS CLI not configured"
fi

# Check environment variables
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo "✅ AWS environment variables set"
else
    echo "⚠️  AWS environment variables not set"
fi

# Test credentials
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS credentials working"
else
    echo "❌ AWS credentials not working"
fi
```

## Next Steps

1. **Set up AWS credentials using one of the methods above**
2. **Test the credentials using the commands above**
3. **Restart the scheduler:**
   ```bash
   sudo systemctl restart monitor-scheduler
   sudo systemctl status monitor-scheduler
   ```
4. **Check the logs:**
   ```bash
   sudo journalctl -u monitor-scheduler -f
   ```

Once credentials are properly configured, the scheduler should successfully invoke Lambda functions without the "Unable to locate credentials" error. 