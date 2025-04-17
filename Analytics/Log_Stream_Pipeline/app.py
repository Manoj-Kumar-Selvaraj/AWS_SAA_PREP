import logging
import boto3
from flask import Flask
import random
import time

app = Flask(__name__)

# Set up logging
logger = logging.getLogger("werkzeug")
logger.setLevel(logging.INFO)
stream_handler = logging.StreamHandler()
logger.addHandler(stream_handler)

# Create Kinesis client
kinesis_client = boto3.client('kinesis', region_name='us-east-1')

# Kinesis Data Stream name
STREAM_NAME = 'log-stream'

@app.route('/')
def index():
    # Simulate log generation
    log_message = f"INFO: Request received at {time.ctime()}"
    logger.info(log_message)
    
    # Send the log to Kinesis Data Stream
    kinesis_client.put_record(
        StreamName=STREAM_NAME,
        Data=log_message.encode(),
        PartitionKey=str(random.randint(1, 100))
    )
    
    # Simulate error log occasionally
    if random.random() > 0.8:  # 20% chance for an error
        error_log = f"ERROR: Something went wrong at {time.ctime()}"
        logger.error(error_log)
        kinesis_client.put_record(
            StreamName=STREAM_NAME,
            Data=error_log.encode(),
            PartitionKey=str(random.randint(1, 100))
        )

    return "Log generated and sent to Kinesis."

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
