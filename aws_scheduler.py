#!/usr/bin/env python3
"""
AWS Scheduler for Lambda Monitoring System
Runs on EC2 and polls database for monitors to execute
"""

import boto3
import psycopg2
import json
import time
import logging
import os
from datetime import datetime, timedelta

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/opt/monitor-scheduler/scheduler.log'),
        logging.StreamHandler()
    ]
)

class AWSScheduler:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        
        # Database configuration
        self.db_config = {
            'host': 'monitoring-db.ca1s6qo6gap5.us-east-1.rds.amazonaws.com',
            'database': 'postgres',
            'user': 'postgres',
            'password': 'SuperMan123',
            'port': 5432
        }
        
        # Initialize Lambda clients for each region
        self.lambda_clients = {}
        self.regions = ['us-east-1', 'us-west-2', 'ap-south-1', 'eu-west-1']
        
        for region in self.regions:
            try:
                self.lambda_clients[region] = boto3.client('lambda', region_name=region)
                self.logger.info(f"✅ Lambda client initialized for {region}")
            except Exception as e:
                self.logger.error(f"❌ Failed to initialize Lambda client for {region}: {e}")
        
        # Test database connection
        self.test_database_connection()
    
    def test_database_connection(self):
        """Test database connection"""
        try:
            conn = psycopg2.connect(**self.db_config)
            conn.close()
            self.logger.info("✅ Database connection successful")
        except Exception as e:
            self.logger.error(f"❌ Database connection failed: {e}")
            raise
    
    def get_db_connection(self):
        """Get database connection"""
        return psycopg2.connect(**self.db_config)
    
    def get_due_monitors(self):
        """Get monitors that are due for execution"""
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            
            # Query for monitors that are due
            query = """
                SELECT m.*, 
                       COALESCE(MAX(c."checkedAt"), m."createdAt") as last_check
                FROM monitors m
                LEFT JOIN checks c ON m.id = c."monitorId"
                WHERE m."isActive" = TRUE
                GROUP BY m.id
                HAVING COALESCE(MAX(c."checkedAt"), m."createdAt") + 
                       INTERVAL '1 second' * m."checkInterval" <= NOW()
                ORDER BY m."checkInterval" ASC
            """
            
            cursor.execute(query)
            monitors = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            self.logger.info(f"📊 Found {len(monitors)} monitors due for execution")
            return monitors
            
        except Exception as e:
            self.logger.error(f"❌ Error getting due monitors: {e}")
            return []
    
    def invoke_lambda(self, region, monitor_data):
        """Invoke Lambda function in specified region"""
        try:
            if region not in self.lambda_clients:
                self.logger.error(f"❌ No Lambda client for region {region}")
                return False
            
            # Prepare payload for Lambda
            payload = {
                'monitor_id': monitor_data[0],  # Assuming first column is id
                'name': monitor_data[1],        # Assuming second column is name
                'url': monitor_data[2],         # Assuming third column is url
                'method': monitor_data[3] if len(monitor_data) > 3 else 'GET',
                'expected_status': 200,
                'check_interval': monitor_data[4] if len(monitor_data) > 4 else 300,
                'region': region,
                'monitor_type': 'http',
                'ssl_enabled': False,
                'dns_enabled': False,
                'use_lambda_monitoring': True,
                'lambda_regions': ['us-east-1'],
                'primary_region': 'us-east-1'
            }
            
            # Invoke Lambda function
            response = self.lambda_clients[region].invoke(
                FunctionName='website-monitor-worker',
                InvocationType='Event',  # Asynchronous
                Payload=json.dumps(payload)
            )
            
            self.logger.info(f"✅ Invoked Lambda in {region} for monitor {monitor_data[0]}")
            return True
            
        except Exception as e:
            self.logger.error(f"❌ Failed to invoke Lambda in {region}: {e}")
            return False
    
    def process_due_monitors(self):
        """Process all monitors that are due for execution"""
        monitors = self.get_due_monitors()
        
        for monitor in monitors:
            try:
                self.logger.info(f"🔄 Processing monitor: {monitor[1]} ({monitor[0]})")
                
                # Invoke Lambda in primary region
                if self.invoke_lambda('us-east-1', monitor):
                    self.logger.info(f"✅ Monitor {monitor[0]} scheduled successfully")
                else:
                    self.logger.error(f"❌ Monitor {monitor[0]} failed to schedule")
                
            except Exception as e:
                self.logger.error(f"❌ Error processing monitor {monitor[0]}: {e}")
    
    def run_monitoring_cycle(self):
        """Run one monitoring cycle"""
        try:
            self.logger.info("🔄 Starting monitoring cycle...")
            
            # Process due monitors
            self.process_due_monitors()
            
            self.logger.info("✅ Monitoring cycle completed")
            
        except Exception as e:
            self.logger.error(f"❌ Error in monitoring cycle: {e}")
    
    def run_continuous(self, interval=30):
        """Run continuous monitoring"""
        self.logger.info(f"🚀 Starting AWS Scheduler (interval: {interval}s)")
        self.logger.info(f"🌍 Configured regions: {', '.join(self.regions)}")
        
        while True:
            try:
                self.run_monitoring_cycle()
                time.sleep(interval)
            except KeyboardInterrupt:
                self.logger.info("🛑 Scheduler stopped by user")
                break
            except Exception as e:
                self.logger.error(f"❌ Critical error in scheduler: {e}")
                time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    scheduler = AWSScheduler()
    scheduler.run_continuous(interval=30)  # Check every 30 seconds 