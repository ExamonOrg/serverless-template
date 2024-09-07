import json
import re

import boto3

from petshop_support.const import AWS_REGION

from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger

from aws_lambda_powertools.middleware_factory import lambda_handler_decorator

logger = Logger()
metrics = Metrics(namespace="pet.index")
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
        dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
        table = dynamodb.Table('pets')
        response = table.scan(AttributesToGet=['pet_uuid', 'name', 'breed'])
        logger.info(f"Getting all pets, found {len(response['Items'])}")
        return {
            "statusCode": 200,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(response['Items']),
        }
    except Exception as e:
        Logger.error(e)
        return {"code": 400, "message": "Error"}
