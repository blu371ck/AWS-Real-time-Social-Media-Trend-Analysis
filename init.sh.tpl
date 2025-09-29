#!/bin/bash

sudo yum update -y
sudo yum install git python3.9-pip python3.9-venv -y

runuser -l ec2-user -c '
    cd /home/ec2-user
    git clone https://github.com/blu371ck/AWS-Real-time-Social-Media-Trend-Analysis.git
    cd AWS-Real-time-Social-Media-Trend-Analysis

    python3 -m venv venv
    source venv/bin/activate

    pip3 install -r requirements.txt

'

cat <<EOT >> /home/ec2-user/AWS-Real-time-Social-Media-Trend-Analysis/.env
REDDIT_CLIENT_ID=${reddit_client_id}
REDDIT_CLIENT_SECRET=${reddit_client_secret}
REDDIT_USERNAME=${reddit_username}
REDDIT_PASSWORD=${reddit_password}
REDDIT_USER_AGENT=${reddit_user_agent}
MSK_BOOTSTRAP_BROKERS=${msk_bootstrap_brokers}
EOT