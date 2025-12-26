import json


def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "db init ok", "request_id": getattr(context, "aws_request_id", None)}),
    }
