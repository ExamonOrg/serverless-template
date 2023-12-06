from os import environ
from time import sleep

import pytest
import boto3

from .dynamo_db_client import DynamoDBClient
from .cw_logs_manager import CWLogsClient

AWS_ACCESS_KEY_ID = environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = environ.get("AWS_SECRET_ACCESS_KEY")
client = CWLogsClient(boto3.client(
    service_name='logs',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name='eu-west-1'
))
dyn_client = boto3.resource(
    service_name='dynamodb',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name='eu-west-1'
)


@pytest.fixture(autouse=True)
def my_setup_and_tear_down():
    DynamoDBClient(dyn_client).clean(['pets'])
    client.delete_log_streams()
    yield


@pytest.mark.dynamodb
@pytest.mark.api_gateway
class TestPetFlow:
    def test_endpoints_flow(self, rest_client):
        response = rest_client.get_pets()
        response = rest_client.create_pet()
        assert response.status_code == 200
        pet_uuid = response.json()['pet_uuid']

        response = rest_client.get_pets()
        assert response.status_code == 200
        assert len(response.json()) == 1
        assert response.json()[0]['pet_uuid'] == pet_uuid

        response = rest_client.get_pet(pet_uuid)
        assert response.status_code == 200
        response = rest_client.update_pet(pet_uuid, "Rover", "Shepard")
        assert response.status_code == 201
        response = rest_client.delete_pet(pet_uuid)
        assert response.status_code == 202

    def test_logs(self, rest_client):
        response = rest_client.create_pet()
        pet_uuid = response.json()['pet_uuid']

        rest_client.get_pets()
        rest_client.get_pet(pet_uuid)
        rest_client.update_pet(pet_uuid, "Rover", "Shepard")
        rest_client.delete_pet(pet_uuid)
        sleep(10)

        assert "Creating pet" in client.get_logs("/aws/lambda/petshop_create_pet")
        assert f"Getting pet: {pet_uuid}" in client.get_logs("/aws/lambda/petshop_get_pet")
        assert f"Getting all pets, found 1" in client.get_logs("/aws/lambda/petshop_index_pet")
        assert f"Updating pet: {pet_uuid}" in client.get_logs("/aws/lambda/petshop_update_pet")
        assert f"Deleting pet: {pet_uuid}" in client.get_logs("/aws/lambda/petshop_delete_pet")
