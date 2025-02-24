# Create a S3 bucket and file.

# Uploading

## We can pass the metadata like this 

aws s3api put-object --bucket awssaptestbucketmanoj --key meta-data/Readme.md --body Readme.md --metadata Planet=Mars

## gET THE DETAILS OR METATDATA ABOUT THE OBJECT


aws s3api head-object --bucket awssaptestbucketmanoj --key meta-data/Readme.md