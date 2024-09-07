from datetime import datetime

import boto3


def get_free_tier_usage():
    # Initialize the Cost Explorer client
    client = boto3.client("ce", region_name="us-east-1")
    print("Client initialized")
    # Set the time period for the query (current month)
    start_date = datetime(datetime.now().year, datetime.now().month, 1).strftime(
        "%Y-%m-%d"
    )
    end_date = datetime.now().strftime("%Y-%m-%d")

    # Define the query parameters
    params = {
        "TimePeriod": {"Start": start_date, "End": end_date},
        "Granularity": "MONTHLY",
        "Metrics": ["UsageQuantity"],
        "Filter": {
            "Dimensions": {"Key": "USAGE_TYPE_GROUP", "Values": ["AWS Free Tier"]}
        },
    }

    try:
        # Execute the query
        response = client.get_cost_and_usage(**params)
        results = response["ResultsByTime"][0]["Total"]["UsageQuantity"]["Amount"]
        print(f"Free Tier Usage: {results}")
    except Exception as e:
        print(f"Error fetching free tier usage: {e}")


# Call the function
get_free_tier_usage()
