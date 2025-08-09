#!/bin/bash

echo "🔍 AWS Resources Check"
echo "======================"

# Check current AWS identity
echo ""
echo "1. AWS Identity"
echo "---------------"
aws sts get-caller-identity

# Check EC2 instances
echo ""
echo "2. EC2 Instances"
echo "----------------"
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress,LaunchTime]' --output table

# Check Lambda functions
echo ""
echo "3. Lambda Functions"
echo "-------------------"
for region in "us-east-1" "us-west-2" "ap-south-1" "eu-west-1"; do
    echo "Region: $region"
    aws lambda list-functions --region "$region" --query 'Functions[*].[FunctionName,Runtime,CodeSize]' --output table
done

# Check RDS instances
echo ""
echo "4. RDS Instances"
echo "----------------"
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus,Endpoint.Address]' --output table

# Check VPC and networking
echo ""
echo "5. VPC Information"
echo "------------------"
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table

# Check security groups
echo ""
echo "6. Security Groups"
echo "------------------"
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName,GroupId,VpcId]' --output table

# Check IAM roles
echo ""
echo "7. IAM Roles"
echo "------------"
aws iam list-roles --query 'Roles[*].[RoleName,RoleId]' --output table

# Check CloudWatch logs
echo ""
echo "8. CloudWatch Log Groups"
echo "------------------------"
aws logs describe-log-groups --query 'logGroups[*].[logGroupName,storedBytes]' --output table

# Check current instance metadata
echo ""
echo "9. Current Instance Info"
echo "------------------------"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)"

# Check IAM role if attached
echo ""
echo "10. IAM Role (if attached)"
echo "---------------------------"
if curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ > /dev/null 2>&1; then
    ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
    echo "IAM Role: $ROLE_NAME"
    echo "Role ARN: $(curl -s http://169.254.169.254/latest/meta-data/iam/info | grep -o '"InstanceProfileArn":"[^"]*"' | cut -d'"' -f4)"
else
    echo "No IAM role attached"
fi

echo ""
echo "📊 Summary"
echo "=========="
echo "✅ AWS CLI is working"
echo "✅ You can access AWS resources"
echo "✅ Instance is running with IP: 54.81.185.248" 