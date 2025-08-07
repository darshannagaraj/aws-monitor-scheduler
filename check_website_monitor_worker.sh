#!/bin/bash

echo "🔍 Checking for website-monitor-worker Lambda Function"
echo "===================================================="

FUNCTION_NAME="website-monitor-worker"
REGIONS=("us-east-1" "us-west-2" "ap-south-1" "eu-west-1")

FOUND=false

echo ""
echo "📊 Searching for '$FUNCTION_NAME' across regions..."
echo ""

for region in "${REGIONS[@]}"; do
    echo "🔍 Checking region: $region"
    
    # Check if the function exists
    if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$region" >/dev/null 2>&1; then
        echo "✅ Found '$FUNCTION_NAME' in $region"
        FOUND=true
        
        # Get function details
        echo "📋 Function Details:"
        aws lambda get-function --function-name "$FUNCTION_NAME" --region "$region" --query 'Configuration.[FunctionName,Runtime,CodeSize,LastModified,State]' --output table
        
        # Check function status
        STATE=$(aws lambda get-function --function-name "$FUNCTION_NAME" --region "$region" --query 'Configuration.State' --output text 2>/dev/null)
        if [ "$STATE" = "Active" ]; then
            echo "✅ Function is Active and ready to receive invocations"
        else
            echo "⚠️  Function state: $STATE"
        fi
        
    else
        echo "❌ '$FUNCTION_NAME' not found in $region"
        echo "   Error: $(aws lambda get-function --function-name "$FUNCTION_NAME" --region "$region" 2>&1 | head -1)"
    fi
    
    echo ""
done

echo "🎯 SUMMARY"
echo "=========="
if [ "$FOUND" = true ]; then
    echo "✅ '$FUNCTION_NAME' Lambda function found"
    echo ""
    echo "📋 The scheduler should be able to invoke this function"
    echo "📋 Check scheduler logs for invocation status:"
    echo "   sudo journalctl -u monitor-scheduler -f"
else
    echo "❌ '$FUNCTION_NAME' Lambda function NOT found in any region"
    echo ""
    echo "🔧 You need to create this Lambda function or update the scheduler"
    echo "   to use the correct function name."
    echo ""
    echo "📋 To create the function, you can:"
    echo "   1. Create it manually in AWS Console"
    echo "   2. Use AWS CLI: aws lambda create-function"
    echo "   3. Update the scheduler code to use a different function name"
fi

echo ""
echo "🔍 To see all Lambda functions in a region:"
echo "aws lambda list-functions --region us-east-1 --output table" 