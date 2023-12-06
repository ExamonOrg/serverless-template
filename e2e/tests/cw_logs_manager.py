import json
from itertools import chain

import boto3

def flatten_chain(matrix):
    return list(chain.from_iterable(matrix))


class CWLogsClient:
    def __init__(self, cw_logs_client):
        self.cw_logs_client = cw_logs_client

    def get_logs(self, name="/aws/lambda/lambdaFnName"):
        def is_json(myjson):
            try:
                json_object = json.loads(myjson)
            except ValueError as e:
                return False
            return True

        stream_response = self.cw_logs_client.describe_log_streams(
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

        flattened_logs = flatten_chain(all_events)
        log_messages = [log['message'] for log in flattened_logs]
        return [
            json.loads(log_message)['message'] if is_json(log_message) else log_message for log_message in log_messages
        ]

    def delete_log_streams(self, prefix=None):
        try:
            """Delete CloudWatch Logs log streams with given prefix or all."""
            next_token = None

            if prefix:
                log_groups = self.cw_logs_client.describe_log_groups(logGroupNamePrefix=prefix)
            else:
                log_groups = self.cw_logs_client.describe_log_groups()

            for log_group in log_groups['logGroups']:
                log_group_name = log_group['logGroupName']
                print("Delete log group:", log_group_name)

                while True:
                    if next_token:
                        log_streams = self.cw_logs_client.describe_log_streams(
                            logGroupName=log_group_name,
                            nextToken=next_token
                        )
                    else:
                        log_streams = self.cw_logs_client.describe_log_streams(logGroupName=log_group_name)

                    next_token = log_streams.get('nextToken', None)

                    for stream in log_streams['logStreams']:
                        log_stream_name = stream['logStreamName']
                        print("Delete log stream:", log_stream_name)
                        self.cw_logs_client.delete_log_stream(logGroupName=log_group_name,
                                                              logStreamName=log_stream_name)

                    if not next_token or len(log_streams['logStreams']) == 0:
                        break
        except Exception as e:
            print(e)
