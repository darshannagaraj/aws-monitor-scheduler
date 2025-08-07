#!/bin/bash

echo "🔧 Fixing AWS Credentials Issues"
echo "================================"

# Check system time (AWS requires accurate time)
echo ""
echo "1. Checking System Time..."
CURRENT_TIME=$(date)
echo "Current time: $CURRENT_TIME"

# Check if NTP is running
if systemctl is-active --quiet chronyd || systemctl is-active --quiet ntpd; then
    echo "✅ NTP service is running"
else
    echo "⚠️  NTP service not running - this can cause signature issues"
    echo "Starting NTP service..."
    sudo systemctl start chronyd 2>/dev/null || sudo systemctl start ntpd 2>/dev/null
fi

# Clear existing AWS credentials
echo ""
echo "2. Clearing Existing AWS Credentials..."
rm -f ~/.aws/credentials
rm -f ~/.aws/config
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_DEFAULT_REGION

# Check for IAM role
echo ""
echo "3. Checking for IAM Role..."
if curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null 2>&1; then
    ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
    echo "✅ IAM role detected: $ROLE_NAME"
    echo "IAM roles don't need manual credentials - they're automatic!"
    echo "Testing IAM role credentials..."
    if aws sts get-caller-identity > /dev/null 2>&1; then
        echo "✅ IAM role credentials working!"
        aws sts get-caller-identity
        exit 0
    else
        echo "❌ IAM role credentials not working"
    fi
else
    echo "⚠️  No IAM role found - will need manual credentials"
fi

# Install/upgrade AWS CLI
echo ""
echo "4. Installing/Upgrading AWS CLI..."
if command -v aws > /dev/null 2>&1; then
    echo "AWS CLI version: $(aws --version)"
else
    echo "Installing AWS CLI..."
    sudo yum install -y aws-cli
fi

# Create AWS credentials directory
mkdir -p ~/.aws

echo ""
echo "5. Manual AWS Credentials Setup"
echo "================================"
echo "You need to manually configure AWS credentials."
echo ""
echo "Option A: Use 'aws configure' (Recommended)"
echo "  aws configure"
echo "  # Enter your AWS Access Key ID"
echo "  # Enter your AWS Secret Access Key"
echo "  # Enter your default region (e.g., us-east-1)"
echo "  # Enter your output format (json)"
echo ""
echo "Option B: Set environment variables"
echo "  export AWS_ACCESS_KEY_ID=your_access_key"
echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
echo "  export AWS_DEFAULT_REGION=us-east-1"
echo ""
echo "Option C: Create credentials file manually"
echo "  mkdir -p ~/.aws"
echo "  cat > ~/.aws/credentials << EOF"
echo "  [default]"
echo "  aws_access_key_id = YOUR_ACCESS_KEY"
echo "  aws_secret_access_key = YOUR_SECRET_KEY"
echo "  EOF"
echo ""
echo "  cat > ~/.aws/config << EOF"
echo "  [default]"
echo "  region = us-east-1"
echo "  output = json"
echo "  EOF"
echo ""
echo "After setting up credentials, test with:"
echo "  aws sts get-caller-identity"
echo "  aws lambda list-functions --region us-east-1" 