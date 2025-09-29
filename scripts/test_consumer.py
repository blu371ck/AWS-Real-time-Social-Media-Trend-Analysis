from kafka import KafkaConsumer
import json, os, certifi
from dotenv import load_dotenv

load_dotenv()

bootstrap_servers = os.getenv("MSK_BOOTSTRAP_BROKERS")
kafka_topic = "reddit_stream"

consumer = KafkaConsumer(
    kafka_topic,
    bootstrap_servers=bootstrap_servers.split(','),
    value_deserializer=lambda v: json.loads(v.decode('utf-8')),
    security_protocol='SSL',
    ssl_cafile=certifi.where(),
    auto_offset_reset='latest' # Start from the latest message
)
print("Listening for messages...")
for message in consumer:
    print(message.value)