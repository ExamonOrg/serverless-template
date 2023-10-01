from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Logger

import json

logger = Logger()
metrics = Metrics(namespace="examon.get_questions")
tracer = Tracer()


@tracer.capture_method
def a_method() -> bool:
    tracer.put_annotation(key="a_method", value='??')
    return False


@metrics.log_metrics(capture_cold_start_metric=True)
@tracer.capture_lambda_handler
@logger.inject_lambda_context(correlation_id_path="headers.my_request_id_header")
def lambda_handler(event: dict, context: LambdaContext):
    a_method()
    try:
        logger.info(f"Log Message {logger.get_correlation_id()}")
        tracer.put_annotation(key="TracingId", value='1')
        metrics.add_metric(name="GetQuestion", unit=MetricUnit.Count, value=1)
        tracer.put_metadata(key="MetaData",
                            value={
                                "request_id": context.aws_request_id,
                                "function_name": context.function_name,
                                "function_version": context.function_version,
                                "invoked_function_arn": context.invoked_function_arn,
                                "memory_limit_in_mb": context.memory_limit_in_mb
                            })
        return {
            "statusCode": 200,
            "headers": {"content-type": "application/json"},
            "body": json.dumps({"question": "1"}),
        }
    except Exception as e:
        logging.error(e)
        return {"statusCode": 400, "body": {":(": "1"}}
