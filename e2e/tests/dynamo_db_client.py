class DynamoDBClient:
    def __init__(self, dynamodb_client):
        self.dynamodb_client = dynamodb_client

    def clean(self, table_names):
        for table_name in table_names:
            table = self.dynamodb_client.Table(table_name)

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
