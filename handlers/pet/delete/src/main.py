import json

from aws_lambda_powertools import Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger
import boto3

logger = Logger()
metrics = Metrics(namespace="pet.delete")
tracer = Tracer()

region = 'eu-west-1'

@logger.inject_lambda_context(
    correlation_id_path="headers.my_request_id_header",
    log_event=True
)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: dict, context: LambdaContext):
    try:
        dynamodb = boto3.resource('dynamodb', region_name=region)
        table = dynamodb.Table('pets')
        body = json.loads(event['body'])
        pet_uuid = body['id']
        item = table.get_item(Key={'pet_uuid': pet_uuid})['Item']
        logger.info(f"item found: {item}")
        table.delete_item(Key={'pet_uuid': pet_uuid})
        logger.info(f"Deleting pet: {pet_uuid}")
        return {
            "statusCode": 202,
            "headers": {"content-type": "application/json"}
        }
    except Exception as e:
        logger.error(e)
        return {"code": 400, "message": "Error"}
