#!/bin/sh

echo 'Image Upload Bucket name is : image-bucket-dharam Region us-east-1 '

#Image uploaded In s3 bucket and then lambda function 'dharam-func' will be triggered to resize the 
#image and store in same bucket with name resized_<original image name>

#Create Bucket to Upload Image
aws s3 mb s3://image-bucket-dharam --region us-east-1

#Download lambda function and PIL library
aws s3 cp s3://dharam-code/resize . --recursive

#creating lambda
aws lambda create-function --function-name dharam-func \
--runtime python3.6 \
--role arn:aws:iam::488599217855:role/FullAccess \
--handler resize.lambda_handler \
--zip-file fileb://code.zip \
--timeout 300 \
--region us-east-1

#Adding permissions to lambda
aws lambda add-permission \
--function-name dharam-func \
--region "us-east-1" \
--statement-id "1" \
--action "lambda:InvokeFunction" \
--principal s3.amazonaws.com \
--source-arn arn:aws:s3:::*

arn=$(aws lambda get-function-configuration --function-name dharam-func --region us-east-1 --query '{FunctionArn:FunctionArn}' --output text)

echo "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\":"\""$arn"\"",
      \"Events\": [\"s3:ObjectCreated:*\"]
    }
  ]
}" > events.json

#adding event to S3 bucket so that lambda can be triggered
aws s3api put-bucket-notification-configuration \
--bucket image-bucket-dharam \
--notification-configuration file://events.json

#rm resize.py -r PIL -r Pillow-4.2.0.data -r Pillow-4.2.0.dist-info -r code.zip