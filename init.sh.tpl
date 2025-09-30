#!/bin/bash

# 1. Update system and install dependencies
yum update -y
yum install git java-11-amazon-corretto -y

# 2. Download and Extract Kafka Tools to /opt/
cd /opt
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
rm kafka_2.13-3.6.0.tgz

# 3. Switch to the ec2-user and execute the rest of the script
# This 'heredoc' is a much safer way to run multi-line commands as another user
su - ec2-user <<EOF

# Commands inside this block are run as ec2-user

# 4. Create the Kafka client properties file
cat <<EOT > /home/ec2-user/client.properties
security.protocol=SSL
EOT

# 5. Create the Kafka Topic
# Note: Terraform expands the variables before the 'su' command runs
/opt/kafka_2.13-3.6.0/bin/kafka-topics.sh --create \
  --topic reddit_stream \
  --bootstrap-server "${msk_bootstrap_brokers}" \
  --command-config /home/ec2-user/client.properties

# 6. Set up the Python Application
cd /home/ec2-user
git clone https://github.com/blu371ck/AWS-Real-time-Social-Media-Trend-Analysis.git
cd AWS-Real-time-Social-Media-Trend-Analysis

python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 7. Create the .env file
cat <<EOT > /home/ec2-user/AWS-Real-time-Social-Media-Trend-Analysis/.env
REDDIT_CLIENT_ID=${reddit_client_id}
REDDIT_CLIENT_SECRET=${reddit_client_secret}
REDDIT_USERNAME=${reddit_username}
REDDIT_PASSWORD=${reddit_password}
REDDIT_USER_AGENT=${reddit_user_agent}
MSK_BOOTSTRAP_BROKERS=${msk_bootstrap_brokers}
EOT

EOF