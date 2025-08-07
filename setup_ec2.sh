#!/bin/bash

# AWS Monitor Scheduler - EC2 Setup Script
# This script sets up the scheduler on EC2 instances with older Python/OpenSSL versions

echo "🚀 Setting up AWS Monitor Scheduler on EC2..."

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Python 3.9 if available (better compatibility)
echo "🐍 Installing Python 3.9..."
sudo yum install -y python39 python39-pip python39-devel

# Create symlink for python3 to point to python3.9
if [ -f /usr/bin/python3.9 ]; then
    sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
    sudo ln -sf /usr/bin/pip3.9 /usr/bin/pip3
    echo "✅ Python 3.9 installed and configured"
else
    echo "⚠️  Python 3.9 not available, using system Python"
fi

# Install development tools for psycopg2
echo "🔧 Installing development tools..."
sudo yum groupinstall -y "Development Tools"
sudo yum install -y postgresql-devel

# Upgrade pip to latest version
echo "⬆️  Upgrading pip..."
python3 -m pip install --upgrade pip

# Install dependencies with compatibility constraints
echo "📚 Installing Python dependencies..."
python3 -m pip install --user -r requirements.txt

# Create logs directory
echo "📁 Creating logs directory..."
mkdir -p logs

# Make the scheduler executable
chmod +x aws_scheduler.py

# Create systemd service file
echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/monitor-scheduler.service > /dev/null <<EOF
[Unit]
Description=AWS Monitor Scheduler
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/monitor-scheduler
ExecStart=/usr/bin/python3 aws_scheduler.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable monitor-scheduler

echo "✅ Setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Update database configuration in aws_scheduler.py"
echo "3. Start the service: sudo systemctl start monitor-scheduler"
echo "4. Check status: sudo systemctl status monitor-scheduler"
echo "5. View logs: sudo journalctl -u monitor-scheduler -f" 