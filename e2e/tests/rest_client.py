import requests


class RestClient:
    def __init__(self, api_key=None, url=None):
        self.api_key = api_key
        self.invoke_url = url

    def get_pets(self):
        response = requests.get(f'{self.invoke_url}v1/pets', headers=self.headers())
        return response

    def headers(self):
        return {'x-api-key': self.api_key}

    def get_pet(self, uuid):
        response = requests.get(f'{self.invoke_url}v1/pet/{uuid}', headers=self.headers())
        return response

    def create_pet(self, name="Fido", breed="doberman"):
        response = requests.post(
            f'{self.invoke_url}v1/pet',
            json={"name": name, "breed": breed},
            headers=self.headers()
        )
        return response

    def update_pet(self, uuid, name, breed):
        response = requests.put(
            f'{self.invoke_url}v1/pet',
            json={"id": uuid, "name": name, "breed": breed},
            headers=self.headers()
        )
        return response

    def delete_pet(self, uuid):
        response = requests.delete(
            f'{self.invoke_url}v1/pet',
            json={"id": uuid},
            headers=self.headers()
        )
        return response
