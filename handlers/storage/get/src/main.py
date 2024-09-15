import json
from decimal import Decimal

import boto3
from boto3.dynamodb.types import TypeDeserializer
from mirror_storage_support.const import AWS_REGION


def lambda_handler(event: dict, context):
    try:
        dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
        table = dynamodb.Table("mirror_storage")

        response = table.get_item(Key={"object_name": event["pathParameters"]["id"]})

        # Check if the item exists
        if "Item" in response:
            item = response["Item"]
            print("item")
            print(item)
            status_code = 200
            deserializer = TypeDeserializer()

            class DecimalEncoder(json.JSONEncoder):
                def default(self, obj):
                    if isinstance(obj, Decimal):
                        return float(obj)
                    return super(DecimalEncoder, self).default(obj)

            deserialized_item = deserializer.deserialize(item["object_value"])

            return {
                "statusCode": status_code,
                "headers": {"content-type": "application/json"},
                "body": json.dumps(deserialized_item, cls=DecimalEncoder),
            }
        else:
            item = {"error": "Item not found"}
            status_code = 404
            return {
                "statusCode": status_code,
                "headers": {"content-type": "application/json"},
            }

    except Exception:
        raise
