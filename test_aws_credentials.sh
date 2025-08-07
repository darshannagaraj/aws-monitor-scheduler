#!/bin/bash

echo "🧪 Testing AWS Credentials"
echo "=========================="

# Test basic credentials
echo ""
echo "1. Testing Basic Credentials..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ Basic credentials working"
    aws sts get-caller-identity
else
    echo "❌ Basic credentials failed"
    echo "Error: $(aws sts get-caller-identity 2>&1)"
    exit 1
fi

# Test Lambda access
echo ""
echo "2. Testing Lambda Access..."
if aws lambda list-functions --region us-east-1 --max-items 1 > /dev/null 2>&1; then
    echo "✅ Lambda access working"
    echo "Found Lambda functions in us-east-1"
else
    echo "❌ Lambda access failed"
    echo "Error: $(aws lambda list-functions --region us-east-1 --max-items 1 2>&1)"
fi

# Test RDS access
echo ""
echo "3. Testing RDS Access..."
if aws rds describe-db-instances --region us-east-1 --max-items 1 > /dev/null 2>&1; then
    echo "✅ RDS access working"
    echo "Found RDS instances in us-east-1"
else
    echo "❌ RDS access failed"
    echo "Error: $(aws rds describe-db-instances --region us-east-1 --max-items 1 2>&1)"
fi

# Test all configured regions
echo ""
echo "4. Testing All Configured Regions..."
REGIONS=("us-east-1" "us-west-2" "ap-south-1" "eu-west-1")

for region in "${REGIONS[@]}"; do
    echo "Testing region: $region"
    if aws lambda list-functions --region "$region" --max-items 1 > /dev/null 2>&1; then
        echo "✅ Lambda access working in $region"
    else
        echo "❌ Lambda access failed in $region"
    fi
done

echo ""
echo "🎉 Credential testing completed!"
echo ""
echo "If all tests pass, your scheduler should work correctly."
echo "If any tests fail, check your IAM permissions." 