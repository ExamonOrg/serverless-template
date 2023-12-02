from aws_lambda_powertools import Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger

logger = Logger()
metrics = Metrics(namespace="examon.get_questions")
tracer = Tracer()


@logger.inject_lambda_context(
    correlation_id_path="headers.my_request_id_header",
    log_event=True
)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: dict, context: LambdaContext):
    try:
        logger.info(event)
        logger.info(context)
        for rec in event['Records']:
            logger.info('Record: %s', rec)
        return {"code": 200, "message": "Success"}
    except Exception as e:
        Logger.error(e)
        return {"code": 400, "message": "Error"}
