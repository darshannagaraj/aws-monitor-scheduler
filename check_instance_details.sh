#!/bin/bash

echo "🔍 EC2 Instance Details"
echo "======================="

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

echo ""
echo "📋 Instance Information"
echo "----------------------"
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "Public IP: 54.81.185.248"
echo "Private IP: 172.31.32.166"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "Launch Time: $(curl -s http://169.254.169.254/latest/meta-data/ami-launch-index)"

# Get detailed instance info from AWS
echo ""
echo "🔍 AWS Instance Details"
echo "----------------------"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress,LaunchTime,SecurityGroups[*].GroupName]' --output table

# Check instance status
echo ""
echo "📊 Instance Status"
echo "------------------"
aws ec2 describe-instance-status --instance-ids "$INSTANCE_ID" --region "$REGION" --query 'InstanceStatuses[*].[InstanceId,SystemStatus.Status,InstanceStatus.Status]' --output table

# Check security groups
echo ""
echo "🔒 Security Groups"
echo "-----------------"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" --query 'Reservations[*].Instances[*].SecurityGroups[*].[GroupId,GroupName]' --output table

# Check IAM role
echo ""
echo "👤 IAM Role"
echo "-----------"
if curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null 2>&1; then
    ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
    echo "✅ IAM Role attached: $ROLE_NAME"
    
    # Get role details
    echo ""
    echo "Role Details:"
    aws iam get-role --role-name "$ROLE_NAME" --query 'Role.[RoleName,Arn,CreateDate]' --output table
    
    # Get attached policies
    echo ""
    echo "Attached Policies:"
    aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query 'AttachedPolicies[*].[PolicyName,PolicyArn]' --output table
else
    echo "❌ No IAM role attached"
fi

# Check tags
echo ""
echo "🏷️  Instance Tags"
echo "----------------"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" --query 'Reservations[*].Instances[*].Tags[*].[Key,Value]' --output table

# Check monitoring
echo ""
echo "📈 Monitoring"
echo "-------------"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" --query 'Reservations[*].Instances[*].[InstanceId,Monitoring.State]' --output table

echo ""
echo "🎯 Quick Commands"
echo "================="
echo "View instance in console: https://$REGION.console.aws.amazon.com/ec2/v2/home?region=$REGION#InstanceDetails:instanceId=$INSTANCE_ID"
echo "Check CloudWatch logs: aws logs describe-log-groups"
echo "Check Lambda invocations: aws lambda get-function --function-name website-monitor-worker --region us-east-1" 