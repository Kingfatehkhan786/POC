import json
from kafka import KafkaConsumer

# Set up the Kafka consumer with the bootstrap server address and topic name
consumer = KafkaConsumer('your-kafka-topic',
                         bootstrap_servers=['your-kafka-bootstrap-server:9092'],
                         auto_offset_reset='latest',
                         enable_auto_commit=True,
                         group_id='your-kafka-group-id',
                         value_deserializer=lambda x: json.loads(x.decode('utf-8')))

def lambda_handler(event, context):
    # Consume messages from the Kafka cluster
    for message in consumer:
        print(f"Received message: {message.value}")
        
    return {
        'statusCode': 200,
        'body': json.dumps('Messages received from Kafka')
    }
