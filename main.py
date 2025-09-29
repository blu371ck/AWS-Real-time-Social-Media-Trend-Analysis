import praw
import os
import json
from dotenv import load_dotenv
import time
from kafka import KafkaProducer
import certifi # Used for SSL certificate

load_dotenv()

bootstrap_servers = os.getenv("MSK_BOOTSTRAP_BROKERS")

try:
    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers.split(','),
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        # Configure SSL for MSK
        security_protocol='SSL',
        ssl_cafile=certifi.where() # Uses certifi's CA bundle
    )
    print("✅ Kafka Producer connected successfully.")
except Exception as e:
    print(f"❌ Failed to connect Kafka Producer: {e}")
    exit()


# --- Reddit API Authentication ---
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent=os.getenv("REDDIT_USER_AGENT"),
    username=os.getenv("REDDIT_USERNAME"),
    password=os.getenv("REDDIT_PASSWORD"),
)

# --- Main Script ---
subreddit_name = "wallstreetbets"
subreddit = reddit.subreddit(subreddit_name)
kafka_topic = "reddit_stream"

print(f"🚀 Starting to stream comments from r/{subreddit_name} to Kafka topic '{kafka_topic}'...")
print("Press Ctrl+C to stop.")

try:
    for comment in subreddit.stream.comments(skip_existing=True):
        comment_data = {
            "id": comment.id,
            "author": str(comment.author),
            "body": comment.body,
            "created_utc": comment.created_utc,
            "subreddit": subreddit_name
        }
        
        # Send data to Kafka topic
        producer.send(kafka_topic, value=comment_data)
        print(f"Sent comment {comment.id} to Kafka")

except KeyboardInterrupt:
    print("\n🛑 Stream stopped by user.")
except Exception as e:
    print(f"\nAn error occurred: {e}")
finally:
    # Ensure all messages are sent before exiting
    producer.flush()
    producer.close()
    print("Kafka Producer closed.")