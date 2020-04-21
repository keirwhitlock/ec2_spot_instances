#!/bin/bash

yum -y install unzip jq

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -u
rm -rf aws awscliv2.zip

REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
SPOT_REQ_ID=$(/usr/local/bin/aws --region $REGION ec2 describe-instances --instance-ids "$INSTANCE_ID"  --query 'Reservations[0].Instances[0].SpotInstanceRequestId' --output text)

if [ "$SPOT_REQ_ID" != "None" ] ; then
  TAGS=$(/usr/local/bin/aws --region $REGION ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_REQ_ID" --query 'SpotInstanceRequests[0].Tags')
  /usr/local/bin/aws --region $REGION ec2 create-tags --resources "$INSTANCE_ID" --tags "$TAGS"
fi

