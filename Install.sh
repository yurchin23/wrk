#!/bin/bash
sudo apt-get update -y
sudo yum install git -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/Bazhyk/1.git
# place for run tests
# sleep 30m (optional 30/60 etc.) 
aws s3 cp /home/ec2-user/1/Install.sh s3://yurchin777



