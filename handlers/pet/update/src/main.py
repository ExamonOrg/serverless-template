import json

from aws_lambda_powertools import Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger
import boto3

from petshop_support.const import AWS_REGION

logger = Logger()
metrics = Metrics(namespace="pet.update")
tracer = Tracer()

region = 'eu-west-1'


@logger.inject_lambda_context(
    correlation_id_path="headers.my_request_id_header",
    log_event=True
)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: dict, context: LambdaContext):
    dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
    table = dynamodb.Table('pets')
    body = json.loads(event['body'])
    pet_uuid = body['id']
    logger.info(f"Updating pet: {pet_uuid}")
    item = table.get_item(Key={'pet_uuid': pet_uuid})['Item']
    logger.info(f"item: {item}")
    item['name'] = body['name']
    item['breed'] = body['breed']
    table.put_item(
        Item=item
    )
    logger.info(f"success")
    try:
        return {
            "statusCode": 201,
            "headers": {"content-type": "application/json"},
        }
    except Exception as e:
        Logger.error(e)
        return {"code": 400, "message": "Error"}
