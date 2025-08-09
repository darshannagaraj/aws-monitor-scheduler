#!/bin/bash

echo "⏸️  Pausing AWS Monitor Scheduler"
echo "================================"

# Check if scheduler is running
if systemctl is-active --quiet monitor-scheduler; then
    echo "🔄 Stopping monitor-scheduler service..."
    sudo systemctl stop monitor-scheduler
    
    if systemctl is-active --quiet monitor-scheduler; then
        echo "❌ Failed to stop scheduler"
        exit 1
    else
        echo "✅ Scheduler stopped successfully"
    fi
else
    echo "ℹ️  Scheduler is already stopped"
fi

# Check if there are any running Python processes
PYTHON_PROCESSES=$(ps aux | grep "aws_scheduler.py" | grep -v grep | wc -l)
if [ "$PYTHON_PROCESSES" -gt 0 ]; then
    echo "🔄 Stopping Python scheduler processes..."
    pkill -f "aws_scheduler.py"
    echo "✅ Python processes stopped"
else
    echo "ℹ️  No Python scheduler processes found"
fi

echo ""
echo "💰 COST SAVINGS"
echo "==============="
echo "✅ Lambda invocations stopped"
echo "✅ No more AWS charges for monitoring"
echo "✅ Scheduler can be restarted anytime"
echo ""
echo "🔄 To restart monitoring:"
echo "   sudo systemctl start monitor-scheduler"
echo "   sudo systemctl status monitor-scheduler"
echo ""
echo "📊 To check current costs:"
echo "   python3 cost_calculator.py" 