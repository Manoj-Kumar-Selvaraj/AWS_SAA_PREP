#!/usr/bin/bash

# Define the stack name
STACK_NAME="MyEventBusStack"  # Change this to your actual stack name

# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name $STACK_NAME

# Check if the delete command was successful
if [ $? -eq 0 ]; then
    echo "CloudFormation stack '$STACK_NAME' is being deleted..."
else
    echo "Failed to delete stack '$STACK_NAME'."
fi
