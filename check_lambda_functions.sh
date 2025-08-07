#!/bin/bash

echo "🔍 Checking Lambda Functions"
echo "============================"

# Configured regions from the scheduler
REGIONS=("us-east-1" "us-west-2" "ap-south-1" "eu-west-1")

TOTAL_FUNCTIONS=0

for region in "${REGIONS[@]}"; do
    echo ""
    echo "📊 Region: $region"
    echo "-------------------"
    
    # Get Lambda functions in this region
    if aws lambda list-functions --region "$region" --query 'Functions[*].FunctionName' --output table 2>/dev/null; then
        COUNT=$(aws lambda list-functions --region "$region" --query 'length(Functions)' --output text 2>/dev/null)
        if [ "$COUNT" = "None" ] || [ -z "$COUNT" ]; then
            COUNT=0
        fi
        echo ""
        echo "✅ Found $COUNT Lambda functions in $region"
        TOTAL_FUNCTIONS=$((TOTAL_FUNCTIONS + COUNT))
        
        # Show function details
        if [ "$COUNT" -gt 0 ]; then
            echo "📋 Function Details:"
            aws lambda list-functions --region "$region" --query 'Functions[*].[FunctionName,Runtime,CodeSize,LastModified]' --output table
        fi
    else
        echo "❌ Failed to list Lambda functions in $region"
        echo "Error: $(aws lambda list-functions --region "$region" 2>&1 | head -1)"
    fi
done

echo ""
echo "🎯 SUMMARY"
echo "=========="
echo "Total Lambda functions across all regions: $TOTAL_FUNCTIONS"
echo ""
echo "📊 Breakdown by Region:"
for region in "${REGIONS[@]}"; do
    COUNT=$(aws lambda list-functions --region "$region" --query 'length(Functions)' --output text 2>/dev/null)
    if [ "$COUNT" = "None" ] || [ -z "$COUNT" ]; then
        COUNT=0
    fi
    echo "  $region: $COUNT functions"
done

echo ""
echo "🔍 To see more details about a specific function:"
echo "aws lambda get-function --function-name FUNCTION_NAME --region REGION" 