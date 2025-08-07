#!/bin/bash

echo "🔍 Checking Scheduler Lambda Functions"
echo "====================================="

# Check if scheduler is running
echo ""
echo "1. Checking Scheduler Status..."
if systemctl is-active --quiet monitor-scheduler; then
    echo "✅ Scheduler service is running"
else
    echo "❌ Scheduler service is not running"
    echo "Start with: sudo systemctl start monitor-scheduler"
fi

# Check scheduler logs for Lambda invocations
echo ""
echo "2. Recent Lambda Invocations from Logs..."
echo "----------------------------------------"
sudo journalctl -u monitor-scheduler --since "1 hour ago" | grep -E "(Invoked Lambda|Failed to invoke Lambda)" | tail -10

# Check for specific Lambda function names in the code
echo ""
echo "3. Lambda Functions Referenced in Scheduler..."
echo "---------------------------------------------"
if grep -r "lambda" aws_scheduler.py | grep -v "#" | grep -v "import"; then
    echo "Found Lambda references in scheduler code"
else
    echo "No specific Lambda function names found in code"
fi

# Check what Lambda functions the scheduler might be trying to invoke
echo ""
echo "4. Checking for Monitor-Specific Lambda Functions..."
echo "---------------------------------------------------"

# Common naming patterns for monitoring Lambda functions
PATTERNS=("monitor" "website-monitor" "health-check" "uptime" "ping")

for pattern in "${PATTERNS[@]}"; do
    echo "Searching for functions with pattern: $pattern"
    for region in "us-east-1" "us-west-2" "ap-south-1" "eu-west-1"; do
        aws lambda list-functions --region "$region" --query "Functions[?contains(FunctionName, '$pattern')].FunctionName" --output text 2>/dev/null | while read -r function; do
            if [ -n "$function" ]; then
                echo "  Found: $function in $region"
            fi
        done
    done
done

echo ""
echo "5. Quick Lambda Count by Region..."
echo "---------------------------------"
for region in "us-east-1" "us-west-2" "ap-south-1" "eu-west-1"; do
    count=$(aws lambda list-functions --region "$region" --query 'length(Functions)' --output text 2>/dev/null)
    if [ "$count" = "None" ] || [ -z "$count" ]; then
        count=0
    fi
    echo "  $region: $count Lambda functions"
done

echo ""
echo "📋 To see all Lambda functions in a region:"
echo "aws lambda list-functions --region us-east-1 --output table"
echo ""
echo "📋 To see scheduler logs:"
echo "sudo journalctl -u monitor-scheduler -f" 