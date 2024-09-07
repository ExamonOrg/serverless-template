import json

from aws_lambda_powertools import Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger
from petshop_support.const import AWS_REGION

logger = Logger()
metrics = Metrics(namespace="pet.get")
tracer = Tracer()

import boto3

region = 'eu-west-1'

@logger.inject_lambda_context(
    correlation_id_path="headers.my_request_id_header",
    log_event=True
)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: dict, context: LambdaContext):
    try:
        dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
        table = dynamodb.Table('pets')
        pet_uuid = event['pathParameters']['id']
        logger.info(f"Getting pet: {pet_uuid}")
        response = table.get_item(Key={'pet_uuid': pet_uuid})
        return {
            "statusCode": 200,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(response['Item'])
        }
    except Exception as e:
        logger.error(e)
        return {"code": 400, "message": "Error"}
