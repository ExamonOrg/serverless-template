import boto3
from boto3.dynamodb.types import TypeDeserializer

dynamodb = boto3.resource("dynamodb", region_name="eu-west-1")
table = dynamodb.Table("mirror_storage")
response = table.get_item(Key={"object_name": "12345"})

# Check if the item exists
if "Item" in response:
    item = response["Item"]
    print("item")
    print(item)
    status_code = 200
    deserializer = TypeDeserializer()
    from decimal import Decimal
    import json

    class DecimalEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, Decimal):
                return float(obj)
            return super(DecimalEncoder, self).default(obj)

    deserialized_item = deserializer.deserialize(item["object_value"])

    print(json.dumps(deserialized_item, cls=DecimalEncoder))
