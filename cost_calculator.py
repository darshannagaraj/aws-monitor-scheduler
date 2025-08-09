#!/usr/bin/env python3

"""
AWS Lambda Cost Calculator
Calculates estimated monthly costs based on current usage
"""

def calculate_lambda_costs():
    print("💰 AWS Lambda Cost Calculator")
    print("=" * 40)
    
    # Current configuration
    monitors_per_cycle = 2
    cycles_per_hour = 48  # Every 30 seconds
    hours_per_day = 24
    days_per_month = 30
    
    # Calculate invocations
    invocations_per_hour = monitors_per_cycle * cycles_per_hour
    invocations_per_day = invocations_per_hour * hours_per_day
    invocations_per_month = invocations_per_day * days_per_month
    
    print(f"📊 Current Usage:")
    print(f"  - Monitors per cycle: {monitors_per_cycle}")
    print(f"  - Cycles per hour: {cycles_per_hour} (every 30 seconds)")
    print(f"  - Invocations per hour: {invocations_per_hour}")
    print(f"  - Invocations per day: {invocations_per_day:,}")
    print(f"  - Invocations per month: {invocations_per_month:,}")
    
    # AWS Lambda pricing (as of 2024)
    compute_price_per_gb_second = 0.0000166667  # $0.0000166667 per GB-second
    request_price_per_million = 0.20  # $0.20 per 1 million requests
    
    # Free tier limits
    free_requests_per_month = 1_000_000
    free_gb_seconds_per_month = 400_000
    
    print(f"\n💵 AWS Lambda Pricing:")
    print(f"  - Compute: ${compute_price_per_gb_second:.8f} per GB-second")
    print(f"  - Requests: ${request_price_per_million:.2f} per 1 million requests")
    print(f"  - Free tier: {free_requests_per_month:,} requests + {free_gb_seconds_per_month:,} GB-seconds/month")
    
    # Calculate costs
    # Assuming average execution time of 1 second and 128MB memory
    avg_execution_time_seconds = 1
    memory_gb = 0.128  # 128MB = 0.128GB
    
    gb_seconds_per_invocation = avg_execution_time_seconds * memory_gb
    gb_seconds_per_month = invocations_per_month * gb_seconds_per_invocation
    
    # Request costs
    if invocations_per_month <= free_requests_per_month:
        request_cost = 0
        print(f"\n✅ Request costs: FREE (within free tier)")
    else:
        paid_requests = invocations_per_month - free_requests_per_month
        request_cost = (paid_requests / 1_000_000) * request_price_per_million
        print(f"\n💰 Request costs: ${request_cost:.2f} (${paid_requests:,} paid requests)")
    
    # Compute costs
    if gb_seconds_per_month <= free_gb_seconds_per_month:
        compute_cost = 0
        print(f"✅ Compute costs: FREE (within free tier)")
    else:
        paid_gb_seconds = gb_seconds_per_month - free_gb_seconds_per_month
        compute_cost = paid_gb_seconds * compute_price_per_gb_second
        print(f"💰 Compute costs: ${compute_cost:.2f} ({paid_gb_seconds:,.0f} paid GB-seconds)")
    
    total_cost = request_cost + compute_cost
    
    print(f"\n🎯 MONTHLY COST SUMMARY")
    print(f"=" * 30)
    print(f"Total estimated cost: ${total_cost:.2f}")
    
    if total_cost == 0:
        print(f"🎉 Your usage is within the FREE tier!")
    else:
        print(f"💡 Cost optimization tips:")
        print(f"  - Increase check interval to reduce invocations")
        print(f" - Use smaller memory allocation if possible")
        print(f" - Optimize function execution time")
    
    return total_cost

def calculate_cost_with_different_intervals():
    print(f"\n📈 Cost Comparison with Different Intervals")
    print(f"=" * 50)
    
    intervals = [30, 60, 120, 300, 600]  # seconds
    
    for interval in intervals:
        cycles_per_hour = 3600 // interval
        invocations_per_month = 2 * cycles_per_hour * 24 * 30
        
        if invocations_per_month <= 1_000_000:
            cost = 0
        else:
            paid_requests = invocations_per_month - 1_000_000
            cost = (paid_requests / 1_000_000) * 0.20
        
        print(f"  {interval:3d}s interval: {invocations_per_month:8,} invocations/month = ${cost:.2f}")

if __name__ == "__main__":
    calculate_lambda_costs()
    calculate_cost_with_different_intervals()
    
    print(f"\n💡 Recommendations:")
    print(f"  - Current 30s interval: ~2,880 invocations/day")
    print(f"  - Consider 60s interval: ~1,440 invocations/day (50% reduction)")
    print(f"  - Consider 120s interval: ~720 invocations/day (75% reduction)")
    print(f"  - All options are likely within FREE tier") 