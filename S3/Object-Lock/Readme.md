## Create a bucket 

## Turn On BUCKET VERSIONING TO AVOID THIS ERROR:

An error occurred (InvalidBucketState) when calling the PutObjectLockConfiguration operation: Versioning must be 'Enabled' on the bucket to apply a Object Lock configuration


gitpod /workspace $ aws s3api 
> aws s3api put-bucket-versioning --bucket awssaptestbucketmanoj --versioning-configuration Status=Enabled
gitpod /workspace $ 


## Turn on object locking using the command

aws s3api put-object-lock-configuration \
--bucket awssaptestbucketmanoj \
--object-lock-configuration '{"ObjectLockEnabled" : "Enabled", "Rule" : { "DefaultRetention": {"Mode":"GOVERANCE","Days":1}}}'