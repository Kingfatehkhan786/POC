import json
from kafka import KafkaProducer

# Set up the Kafka producer with the bootstrap server address and topic name
producer = KafkaProducer(bootstrap_servers='your-kafka-bootstrap-server:9092',
                         value_serializer=lambda v: json.dumps(v).encode('utf-8'))
topic = 'your-kafka-topic'

def lambda_handler(event, context):
    # Parse the message from the Lambda event
    message = event['message']
    
    # Publish the message to the Kafka cluster
    producer.send(topic, message)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Message published to Kafka')
    }
