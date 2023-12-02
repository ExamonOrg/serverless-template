from aws_lambda_powertools.middleware_factory import lambda_handler_decorator
from typing import Callable
from logger_factory import logger
import re


def log_uuid_values(data, path=''):
    if isinstance(data, dict):
        for key, value in data.items():
            new_path = f'{path}.{key}' if path else key
            if isinstance(value, (dict, list)):
                log_uuid_values(value, new_path)
            elif isinstance(value, str) and re.search(r'uuid', key):
                logger.info(f'{new_path}: {value}')
    elif isinstance(data, list):
        for i, item in enumerate(data):
            new_path = f'{path}[{i}]'
            log_uuid_values(item, new_path)


@lambda_handler_decorator
def uuid_logger_middleware(handler, event, context) -> Callable:
    log_uuid_values(event)
    response = handler(event, context)
    return response
