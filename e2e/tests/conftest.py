import pytest
from os import environ

from .rest_client import RestClient

API_KEY = environ.get("API_KEY").rstrip()
INVOKE_URL = environ.get("INVOKE_URL").rstrip()
AWS_ACCESS_KEY_ID = environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = environ.get("AWS_SECRET_ACCESS_KEY")


@pytest.fixture
def rest_client():
    return RestClient(api_key=API_KEY, url=INVOKE_URL)
