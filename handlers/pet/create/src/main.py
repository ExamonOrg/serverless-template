import json
import boto3

from uuid import uuid4
region = 'eu-west-1'


def lambda_handler(event: dict, context):
    try:
        dynamodb = boto3.resource('dynamodb', region_name=region)
        table = dynamodb.Table('pets')
        pet_uuid = uuid4()
        payload = {
            'pet_uuid': str(pet_uuid),
            'name':  event["name"],
            'breed':  event["breed"]
        }
        response = table.put_item(
            Item=payload
        )
        status_code = response['ResponseMetadata']['HTTPStatusCode']
        return {
            "statusCode": status_code,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(payload) 
        }
    except Exception:
        raise
