import pytest

from .conftest import DynamoDBClient, CWLogsClient
from time import sleep


@pytest.fixture(autouse=True)
def my_setup_and_tear_down():
    DynamoDBClient.clean(['pets'])
    CWLogsClient.delete_log_streams()
    yield


@pytest.mark.dynamodb
@pytest.mark.api_gateway
class TestPetFlow:
    def test_endpoints_flow(self, rest_client):
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

        assert "Creating pet" in CWLogsClient.get_logs("/aws/lambda/petshop_create_pet")
        assert f"Getting pet: {pet_uuid}" in CWLogsClient.get_logs("/aws/lambda/petshop_get_pet")
        assert f"Getting all pets, found 1" in CWLogsClient.get_logs("/aws/lambda/petshop_index_pet")
        assert f"Updating pet: {pet_uuid}" in CWLogsClient.get_logs("/aws/lambda/petshop_update_pet")
        assert f"Deleting pet: {pet_uuid}" in CWLogsClient.get_logs("/aws/lambda/petshop_delete_pet")
