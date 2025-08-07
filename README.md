# AWS Monitor Scheduler

A Python-based scheduler that runs on EC2 to poll the database for monitors and invoke AWS Lambda functions for website monitoring.

## Features

- 🔄 **Continuous Polling**: Checks database every 30 seconds for monitors due to run
- 🌍 **Multi-Region Support**: Can invoke Lambda functions across multiple AWS regions
- 📊 **Database Integration**: Connects to PostgreSQL RDS for monitor configuration
- 🚀 **Lambda Integration**: Asynchronously invokes Lambda functions for monitoring
- 📝 **Comprehensive Logging**: Detailed logs for debugging and monitoring

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Scheduler     │    │   Database      │    │   Lambda        │
│   (EC2)        │◄──►│   (RDS)        │◄──►│   Functions     │
│                 │    │                 │    │   (Multi-Region)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Setup

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd aws-monitor-scheduler
```

### 2. Install Dependencies

```bash
pip3 install -r requirements.txt
```

### 3. Configure Database

Update the database configuration in `aws_scheduler.py`:

```python
self.db_config = {
    'host': 'your-rds-endpoint',
    'database': 'postgres',
    'user': 'postgres',
    'password': 'your-password',
    'port': 5432
}
```

### 4. Deploy to EC2

#### Option A: Manual Setup

1. Copy files to EC2:
```bash
scp -r . ec2-user@your-ec2-ip:/opt/monitor-scheduler/
```

2. Run setup script:
```bash
ssh ec2-user@your-ec2-ip
cd /opt/monitor-scheduler
chmod +x setup_scheduler.sh
./setup_scheduler.sh
```

#### Option B: Automated Setup

```bash
# Run setup script directly
curl -sSL https://raw.githubusercontent.com/your-repo/main/setup_scheduler.sh | bash
```

## Usage

### Start the Scheduler

```bash
# Manual start
python3 aws_scheduler.py

# Or use systemd service
sudo systemctl start monitor-scheduler
sudo systemctl enable monitor-scheduler
```

### Check Status

```bash
# Check service status
sudo systemctl status monitor-scheduler

# View logs
sudo journalctl -u monitor-scheduler -f
```

### Stop the Scheduler

```bash
sudo systemctl stop monitor-scheduler
```

## Configuration

### Environment Variables

- `DB_HOST`: RDS endpoint
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_PORT`: Database port

### Monitor Configuration

Monitors are stored in the database with the following structure:

```sql
CREATE TABLE monitors (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    method VARCHAR(10) DEFAULT 'GET',
    "checkInterval" INTEGER DEFAULT 300,
    "isActive" BOOLEAN DEFAULT TRUE,
    "monitorType" VARCHAR(50) DEFAULT 'http',
    "useLambdaMonitoring" BOOLEAN DEFAULT TRUE,
    "lambdaRegions" TEXT DEFAULT '[]',
    "primaryRegion" VARCHAR(50) DEFAULT 'us-east-1',
    "expectedStatus" INTEGER DEFAULT 200,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Monitoring

### Logs

- **Service Logs**: `/var/log/syslog` or `journalctl -u monitor-scheduler`
- **Application Logs**: `/opt/monitor-scheduler/scheduler.log`

### Metrics

The scheduler logs the following metrics:
- Number of monitors due for execution
- Lambda invocation success/failure rates
- Database connection status
- System errors and warnings

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check RDS security group allows EC2 access
   - Verify database credentials
   - Ensure RDS instance is running

2. **Lambda Invocation Failed**
   - Check IAM permissions for Lambda invocation
   - Verify Lambda function exists in target regions
   - Check Lambda function configuration

3. **Service Won't Start**
   - Check Python dependencies are installed
   - Verify file permissions
   - Check systemd service configuration

### Debug Mode

Run the scheduler in debug mode:

```bash
python3 aws_scheduler.py --debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details. 