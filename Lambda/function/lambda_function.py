import json
from time_utils import get_current_utc_time  # imported from the layer

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Current UTC time',
            'time': get_current_utc_time()
        })
    }
