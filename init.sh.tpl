#!/bin/bash

# 1. Update system and install dependencies
yum update -y
yum install git java-11-amazon-corretto -y

# 2. Download and Extract Kafka Tools to /opt/
cd /opt
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz

rm kafka_2.13-3.6.0.tgz

# --- Run all user-specific setup as the ec2-user ---
runuser -l ec2-user -c '
  # 3. Create the Kafka client properties file in the user's home directory
  cat <<EOT > /home/ec2-user/client.properties
security.protocol=SSL
EOT

  # 4. Create the Kafka Topic using full paths and correct variable syntax
  /opt/kafka_2.13-3.6.0/bin/kafka-topics.sh --create \
    --topic reddit_stream \
    --bootstrap-server "${msk_bootstrap_brokers}" \
    --command-config /home/ec2-user/client.properties

  # 5. Set up the Python Application
  cd /home/ec2-user
  git clone https://github.com/blu371ck/AWS-Real-time-Social-Media-Trend-Analysis.git
  cd AWS-Real-time-Social-Media-Trend-Analysis

  python3.9 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt

  # 6. Create the .env file with all credentials
  cat <<EOT > /home/ec2-user/AWS-Real-time-Social-Media-Trend-Analysis/.env
REDDIT_CLIENT_ID=${reddit_client_id}
REDDIT_CLIENT_SECRET=${reddit_client_secret}
REDDIT_USERNAME=${reddit_username}
REDDIT_PASSWORD=${reddit_password}
REDDIT_USER_AGENT=${reddit_user_agent}
MSK_BOOTSTRAP_BROKERS=${msk_bootstrap_brokers}
EOT
'