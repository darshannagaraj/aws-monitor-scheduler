#!/bin/bash

# Quick fix for urllib3/OpenSSL compatibility issue on EC2
echo "🔧 Fixing urllib3/OpenSSL compatibility issue..."

# Uninstall problematic urllib3 version
pip3 uninstall -y urllib3

# Install compatible urllib3 version
pip3 install --user "urllib3<2.0.0"

# Reinstall boto3 with compatible urllib3
pip3 install --user --force-reinstall boto3

echo "✅ urllib3 compatibility fix applied!"
echo "🔄 Try running the scheduler again: python3 aws_scheduler.py" 