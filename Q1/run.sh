#!/bin/sh
echo 'Source Bucket Name'
read srcbucket

echo 'Enter Region for replication'
read region

destbucket="replicate-${srcbucket}"

echo 'Your Bucket will be replicated with name ${destbucket} in ${region}'

echo "Your bucket has replicated in Mumbai region with name ${destbucket}"

aws s3 mb s3://${destbucket} --region $region

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