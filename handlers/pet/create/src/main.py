import json
from uuid import uuid4

import boto3

from petshop_support.const import AWS_REGION


def lambda_handler(event: dict, context):
    try:
        dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
        table = dynamodb.Table("pets")
        pet_uuid = uuid4()
        payload = {
            "pet_uuid": str(pet_uuid),
            "name": "Name",
            "breed": "Breed",
            "age": 3,
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
