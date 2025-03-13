#!/usr/bin/bash

# Variables
STACK_NAME="MyEventBusStack"
TEMPLATE_FILE="template.yml"
CHANGE_SET_NAME="MyChangeSet"

# Validate the template
echo "Validating CloudFormation template..."
aws cloudformation validate-template --template-body file://$TEMPLATE_FILE

if [ $? -ne 0 ]; then
    echo "Template validation failed. Fix errors before proceeding."
    exit 1
fi
echo "Template is valid!"

# Create a change set for review
echo "Creating change set for review..."
aws cloudformation create-change-set --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --change-set-name $CHANGE_SET_NAME --change-set-type CREATE

if [ $? -ne 0 ]; then
    echo "Failed to create change set."
    exit 1
fi
echo "Change set '$CHANGE_SET_NAME' created successfully."

# Wait for the change set to be created
echo "Waiting for change set to be available..."
aws cloudformation wait change-set-create-complete --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME

# Describe the change set (Review the changes)
echo "Review the following changes before applying:"
aws cloudformation describe-change-set --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME --query "Changes"

# Prompt user for confirmation
read -p "Do you want to apply these changes? (yes/no): " confirm
if [[ $confirm == "yes" ]]; then
    # Execute the change set
    echo "Deploying stack..."
    aws cloudformation execute-change-set --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME
    echo "Deployment initiated!"
else
    echo "Deployment canceled."
fi
