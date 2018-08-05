#!/bin/sh
echo 'Source Bucket Name'
read srcbucket

echo 'Enter Region for replication'
read region

destbucket="replicate-${srcbucket}"

echo 'Your Bucket will be replicated with name ${destbucket} in ${region}'

echo "Your bucket has replicated in Mumbai region with name ${destbucket}"

aws s3 mb s3://${destbucket} --region $region

queueurl=$(aws sqs get-queue-url --queue-name general-queue \
--query QueueUrl --output text)

#getting queuearn
queuearn=$(aws sqs get-queue-attributes \
--queue-url $queueurl --attribute-names All --query Attributes.QueueArn --output text)

echo "{
    \"QueueConfigurations\": [
        {
            \"Id\": \"queue-event-bucket\",
            \"QueueArn\": \""$queuearn"\",
            \"Events\": [
                \"s3:ObjectCreated:*\"
            ]
	}
    ]
}" > bucket-event-config.json

 aws s3api put-bucket-notification-configuration \
--bucket $srcbucket \
--notification-configuration file://bucket-event-config.json

rm bucket-event-config.json