#!/bin/sh

#creating queue
queueurl=$(aws sqs create-queue --queue-name general-queue \
--attributes "MessageRetentionPeriod"="259200","VisibilityTimeout"="60" --query QueueUrl --output text)

#getting queuearn
queuearn=$(aws sqs get-queue-attributes \
--queue-url $queueurl --attribute-names All --query Attributes.QueueArn --output text)


#Attaching Policy to queue allowing s3 to send message to queue
aws sqs set-queue-attributes \
--queue-url $queueurl \
--attributes '{"Policy" :"{\"Version\": \"2012-10-17\",\"Statement\": [{\"Sid\": \"VisualEditor0\",\"Effect\": \"Allow\",\"Principal\":\"*\", \"Action\": \"sqs:SendMessage\",\"Resource\": \"'"$queuearn"'\"}]}"}'



#creating key pair
aws ec2 create-key-pair --key-name CRRR --query 'KeyMaterial' --output text > CRRR.pem
file=CRRR.pem
chmod 400 $file

#download files from s3 bucket
aws s3 cp s3://dharam-code/CRR . --recursive

#create Instance
aws ec2 run-instances --iam-instance-profile Name=FullAccess --image-id ami-b70554c8 --count 1 --subnet-id subnet-de0385f2 --instance-type t2.micro --key-name CRRR --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=CRinstance}]" --region us-east-1
instanceid=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=CRinstance" | grep InstanceId | grep -E -o "i\-[0-9A-Za-z]+")
ip=$(aws ec2 describe-instances --instance-ids $instanceid --region us-east-1 | grep PublicIpAddress | awk -F ":" '{print $2}' | sed 's/[",]//g')

#curr=$(pwd)
scp -i `echo $file` ~/infinite.sh ec2-user@`echo $ip`:~/.
scp -i `echo $file` ~/getReceipt.py ec2-user@`echo $ip`:~/.
scp -i `echo $file` ~/parse-1.py ec2-user@`echo $ip`:~/.
scp -i `echo $file` ~/parse-2.py ec2-user@`echo $ip`:~/.
scp -i `echo $file` ~/message.json ec2-user@`echo $ip`:~/.

rm infinite.sh getReceipt.py parse-1.py parse-2.py message.json

#ssh to instance and start infinite script in screen background 
ssh -o CheckHostIP=no -i `echo $file` ec2-user@`echo $ip` 'bash -s'<<'EXECUTE'
echo $USER
aws configure set default.region us-east-1
screen -dm -S infinite /bin/bash infinite.sh 
EXECUTE

