aws ec2 create-vpc --cidr-block "192.0.0.0/24" --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value="DATESTVPC"}]"
VpcId": "vpc-0b126353a2ea46e80
aws elbv2 create-target-group --name DATESTTG --target-type instance --protocol HTTPS --port 443 --vpc-id vpc-0b126353a2ea46e80 --ip-address-type ipv4 --health-check-enabled --healthy-threshold-count 5 --unhealthy-threshold-count 2 --health-check-timeout-seconds 5 --health-check-interval-seconds 30 
"TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:686255975511:targetgroup/DATESTTG/96592b808c119279",
