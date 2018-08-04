#!/bin/sh
echo 'Enter private file path for 1st instance'
read first

echo 'Enter private file path for 2nd instance'
read second

ssh-add $first
ssh-add $second

echo "Set up done..."

#Connection from local to 1st instance
#-A flag for agent forwarding
#ssh -A instance1@ip 

#connection from 1st to 2nd instance
#here no use of -A flag since 2nd instance is the last one to connect to
#ssh instance2@ip 