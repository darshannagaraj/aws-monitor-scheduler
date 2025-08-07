#!/bin/bash

echo "🔍 AWS Credentials Diagnostic Tool"
echo "=================================="

# Check if IAM role is available
echo ""
echo "1. Checking IAM Role..."
if curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null 2>&1; then
    ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
    echo "✅ IAM role detected: $ROLE_NAME"
else
    echo "⚠️  No IAM role found"
fi

# Check AWS CLI configuration
echo ""
echo "2. Checking AWS CLI Configuration..."
if command -v aws > /dev/null 2>&1; then
    echo "✅ AWS CLI installed"
    aws configure list
else
    echo "❌ AWS CLI not installed"
    echo "Install with: sudo yum install -y aws-cli"
fi

# Check environment variables
echo ""
echo "3. Checking Environment Variables..."
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo "✅ AWS_ACCESS_KEY_ID is set"
else
    echo "⚠️  AWS_ACCESS_KEY_ID not set"
fi

if [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "✅ AWS_SECRET_ACCESS_KEY is set"
else
    echo "⚠️  AWS_SECRET_ACCESS_KEY not set"
fi

if [ -n "$AWS_DEFAULT_REGION" ]; then
    echo "✅ AWS_DEFAULT_REGION is set: $AWS_DEFAULT_REGION"
else
    echo "⚠️  AWS_DEFAULT_REGION not set"
fi

# Test credentials
echo ""
echo "4. Testing AWS Credentials..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS credentials working"
    aws sts get-caller-identity
else
    echo "❌ AWS credentials not working"
    echo "Error: Unable to locate credentials"
fi

# Test Lambda access
echo ""
echo "5. Testing Lambda Access..."
if aws lambda list-functions --region us-east-1 --max-items 1 > /dev/null 2>&1; then
    echo "✅ Lambda access working"
else
    echo "❌ Lambda access failed"
fi

echo ""
echo "📋 Recommendations:"
echo "=================="

if ! curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null 2>&1; then
    echo "🔧 Option 1 (Recommended): Attach IAM role to EC2 instance"
    echo "   - Go to AWS Console → EC2 → Select your instance"
    echo "   - Actions → Security → Modify IAM role"
    echo "   - Create/select a role with Lambda and RDS permissions"
fi

if ! command -v aws > /dev/null 2>&1; then
    echo "🔧 Option 2: Install and configure AWS CLI"
    echo "   - sudo yum install -y aws-cli"
    echo "   - aws configure"
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "🔧 Option 3: Set environment variables"
    echo "   - export AWS_ACCESS_KEY_ID=your_key"
    echo "   - export AWS_SECRET_ACCESS_KEY=your_secret"
    echo "   - export AWS_DEFAULT_REGION=us-east-1"
fi

echo ""
echo "📖 For detailed instructions, see: AWS_CREDENTIALS_SETUP.md" 