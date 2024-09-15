import json

import boto3
from boto3.dynamodb.types import TypeSerializer
from mirror_storage_support.const import AWS_REGION


def lambda_handler(event: dict, context):
    try:
        dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
        table = dynamodb.Table("mirror_storage")
        body = json.loads(event["body"])
        print("body")
        print(body)
        object_value = body["object_value"]
        serializer = TypeSerializer()
        serialized_object_value = serializer.serialize(object_value)
        payload = {
            "object_name": event["pathParameters"]["id"],
            "object_value": serialized_object_value,
        }
        response = table.put_item(Item=payload)
        status_code = response["ResponseMetadata"]["HTTPStatusCode"]
        return {
            "statusCode": status_code,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(payload),
        }
    except Exception:
        raise
