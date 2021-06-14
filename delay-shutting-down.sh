sleep 1m
aws ec2 terminate-instances --instance-ids ${aws_instance.webserver.id}