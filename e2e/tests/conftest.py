import pytest
import requests
import boto3
import json
from itertools import chain


def flatten_chain(matrix):
    return list(chain.from_iterable(matrix))


API_KEY = environ.get("API_KEY")
INVOKE_URL = environ.get("INVOKE_URL")
AWS_ACCESS_KEY_ID = environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = environ.get("AWS_SECRET_ACCESS_KEY")

dynamodb_client = boto3.resource(
    service_name='dynamodb',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name='eu-west-1'
)

cw_logs_client = boto3.client(
    service_name='logs',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name='eu-west-1'
)


class CWLogsClient:
    @staticmethod
    def get_logs(name="/aws/lambda/lambdaFnName"):
        def is_json(myjson):
            try:
                json_object = json.loads(myjson)
            except ValueError as e:
                return False
            return True

        stream_response = cw_logs_client.describe_log_streams(
            logGroupName=name,  # Can be dynamic
            orderBy='LastEventTime',  # For the latest events
            limit=1  # the last latest event, if you just want one
        )

        if stream_response["logStreams"] == []:
            return False

        all_events = []
        for log_stream in stream_response["logStreams"]:
            latest_log_stream_name = log_stream["logStreamName"]

            event_response = cw_logs_client.get_log_events(
                logGroupName=name,
                logStreamName=latest_log_stream_name,
                startTime=0,
                endTime=10000000000000,
            )

            all_events.append(event_response["events"])

        flattened_logs =  flatten_chain(all_events)
        log_messages = [log['message'] for log in flattened_logs]
        return [
            json.loads(log_message)['message'] if is_json(log_message) else log_message for log_message in log_messages
        ]

    @staticmethod
    def delete_log_streams(prefix=None):
        try:
            """Delete CloudWatch Logs log streams with given prefix or all."""
            next_token = None

            if prefix:
                log_groups = cw_logs_client.describe_log_groups(logGroupNamePrefix=prefix)
            else:
                log_groups = cw_logs_client.describe_log_groups()

            for log_group in log_groups['logGroups']:
                log_group_name = log_group['logGroupName']
                print("Delete log group:", log_group_name)

                while True:
                    if next_token:
                        log_streams = cw_logs_client.describe_log_streams(
                            logGroupName=log_group_name,
                            nextToken=next_token
                        )
                    else:
                        log_streams = cw_logs_client.describe_log_streams(logGroupName=log_group_name)

                    next_token = log_streams.get('nextToken', None)

                    for stream in log_streams['logStreams']:
                        log_stream_name = stream['logStreamName']
                        print("Delete log stream:", log_stream_name)
                        cw_logs_client.delete_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)

                    if not next_token or len(log_streams['logStreams']) == 0:
                        break
        except Exception as e:
            print(e)


class DynamoDBClient:
    @staticmethod
    def clean(table_names):
        for table_name in table_names:
            table = dynamodb_client.Table(table_name)

            # get the table keys
            table_key_names = [key.get("AttributeName") for key in table.key_schema]

            # Only retrieve the keys for each item in the table (minimize data transfer)
            projection_expression = ", ".join('#' + key for key in table_key_names)
            expression_attr_names = {'#' + key: key for key in table_key_names}

            counter = 0
            page = table.scan(
                ProjectionExpression=projection_expression,
                ExpressionAttributeNames=expression_attr_names
            )
            with table.batch_writer() as batch:
                while page["Count"] > 0:
                    counter += page["Count"]
                    # Delete items in batches
                    for itemKeys in page["Items"]:
                        batch.delete_item(Key=itemKeys)
                    # Fetch the next page
                    if 'LastEvaluatedKey' in page:
                        page = table.scan(
                            ProjectionExpression=projection_expression,
                            ExpressionAttributeNames=expression_attr_names,
                            ExclusiveStartKey=page['LastEvaluatedKey']
                        )
                    else:
                        break


class RestClient:
    def __init__(self, api_key=None, url=None):
        self.api_key = api_key
        self.invoke_url = url

    def get_pets(self):
        headers = {'x-api-key': self.api_key}
        response = requests.get(f'{self.invoke_url}v1/pets', headers=headers)
        return response

    def get_pet(self, uuid):
        headers = {'x-api-key': self.api_key}
        response = requests.get(f'{self.invoke_url}v1/pet/{uuid}', headers=headers)
        return response

    def create_pet(self, name="Fido", breed="doberman"):
        headers = {'x-api-key': self.api_key}
        response = requests.post(f'{self.invoke_url}v1/pet',
                                 json={"name": name, "breed": breed},
                                 headers=headers)
        return response

    def update_pet(self, uuid, name, breed):
        headers = {'x-api-key': self.api_key}
        response = requests.put(f'{self.invoke_url}v1/pet',
                                json={
                                    "id": uuid, "name": name, "breed": breed
                                },
                                headers=headers)
        return response

    def delete_pet(self, uuid):
        headers = {'x-api-key': self.api_key}
        response = requests.delete(f'{self.invoke_url}v1/pet',
                                   json={"id": uuid},
                                   headers=headers)
        return response


@pytest.fixture
def rest_client():
    return RestClient(api_key=API_KEY, url=INVOKE_URL)
