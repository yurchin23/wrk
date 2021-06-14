#--------------------------------------------------------------#
#Create instance EC2 and security group, install security group#
#--------------------------------------------------------------#


 provider "aws" {

  region = "us-east-2"

 }

 resource "aws_instance" "webserver" {
    ami = "ami-0d8d212151031f51c"
    instance_type = "t2.micro"
    iam_instance_profile = "${aws_iam_instance_profile.s3_profile.name}"  # Role for s3
    vpc_security_group_ids = [aws_security_group.webserver.id]            # create dependence
    user_data = file("Install.sh")
    key_name                 =   "aws_key_ohio"
  connection {                                                            # SSH connections to my Instance
    type        = "ssh" 
    user        = "ec2-user"
    private_key = file("~/secret/aws_key_ohio.pem")
    host        = self.public_ip                                          # Instance Public IP
  }
  provisioner "file" {
    source      = "Install.sh"
    destination = "/tmp/Install.sh"
  }

   provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/Install.sh",
      "sudo /tmp/Install.sh",
    ]
  }
 }

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  role = "${aws_iam_role.full_s3_role.id}"

  policy = "${file("policy_s3.json")}"
}

resource "aws_iam_role" "full_s3_role" {
  name = "full_s3_role"

  assume_role_policy = "${file("role_s3.json")}"
}
resource "aws_iam_instance_profile" "s3_profile" {
  name = "s3_profile"
  role = "${aws_iam_role.full_s3_role.name}"
}

resource "aws_security_group" "webserver" {
  name        = "webserver security group"
  description = "Security group"

  ingress {
                                                                                          #in (server)
    from_port   = 80
                                                                                          #if create new rule, just add same ingress with new param, same to engress
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
   from_port = 443
   to_port = 443
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
                                                                                          #out (server)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }
}
  
resource "aws_s3_bucket" "yurchin777" {
  bucket = "yurchin777"
  acl    = "public-read"   # or can be "public-read"
  tags = {

    Name        = "My bucket"

    Environment = "Dev"

  }
}

resource "null_resource" "reboo_instance" {

  provisioner "local-exec" {
    command     = <<EOF
      aws ec2 terminate-instances --instance-ids ${aws_instance.webserver.id}
     EOF
  }
}

  module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "172.31.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "instance_ips" {                                 # Instance "Webserver" - Public IP
  value = aws_instance.webserver.*.public_ip
}











