#!/bin/bash

# Define variables
MFA_DEVICE_ARN="arn:aws:iam::123456789012:mfa/YourMFADeviceName"
AWS_PROFILE="default" # Replace with your AWS CLI profile name

read -p "Enter your MFA code: " MFA_CODE

# Generate creds
SESSION_OUTPUT=$(aws sts get-session-token \
  --serial-number $MFA_DEVICE_ARN \
  --token-code $MFA_CODE \
  --region us-east-1 \
  --duration-seconds 7200) # Adjust duration as needed

# Extract creds
AWS_ACCESS_KEY_ID=$(echo $SESSION_OUTPUT | grep -o '"AccessKeyId":[^,]*' | awk -F'"' '{print $4}')
AWS_SECRET_ACCESS_KEY=$(echo $SESSION_OUTPUT | grep -o '"SecretAccessKey":[^,]*' | awk -F'"' '{print $4}')
AWS_SESSION_TOKEN=$(echo $SESSION_OUTPUT | grep -o '"SessionToken":[^,]*' | awk -F'"' '{print $4}')

# Update AWS CLI profile with creds
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $AWS_PROFILE
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $AWS_PROFILE
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $AWS_PROFILE

# Confirm update
echo "AWS CLI profile '$AWS_PROFILE' updated with temporary credentials!"
echo "Credentials valid for 2 hour. Use 'unset AWS_SESSION_TOKEN' to clear them."