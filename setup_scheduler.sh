#!/bin/bash

echo "🚀 Setting up AWS Monitor Scheduler"
echo "===================================="

# Create scheduler directory
sudo mkdir -p /opt/monitor-scheduler
cd /opt/monitor-scheduler

# Install Python dependencies
echo "📦 Installing Python dependencies..."
sudo yum install -y python3 python3-pip git
pip3 install boto3 psycopg2-binary requests dnspython

# Create systemd service
echo "📋 Creating systemd service..."
sudo tee /etc/systemd/system/monitor-scheduler.service > /dev/null << 'EOF'
[Unit]
Description=Monitor Scheduler Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/monitor-scheduler
ExecStart=/usr/bin/python3 aws_scheduler.py
Restart=always
RestartSec=10
Environment=DB_HOST=monitoring-db.ca1s6qo6gap5.us-east-1.rds.amazonaws.com
Environment=DB_NAME=postgres
Environment=DB_USER=postgres
Environment=DB_PASSWORD=SuperMan123
Environment=DB_PORT=5432

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
echo "🚀 Enabling and starting scheduler service..."
sudo systemctl enable monitor-scheduler
sudo systemctl start monitor-scheduler

# Check status
echo "📊 Checking service status..."
sudo systemctl status monitor-scheduler

echo "✅ Scheduler setup completed!"
echo "📋 Recent Logs:"
sudo journalctl -u monitor-scheduler --no-pager -n 10 