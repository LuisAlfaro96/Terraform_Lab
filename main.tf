resource "aws_vpc" "luis_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "luis_public_subnet" {
  vpc_id                  = aws_vpc.luis_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    name = "luis_subnet"

  }

}

resource "aws_internet_gateway" "luis_internet_gateway" {
  vpc_id = aws_vpc.luis_vpc.id

  tags = {
    Name = "dev_internet_gateway"
  }

}

resource "aws_route_table" "luis_public_rt" {
  vpc_id = aws_vpc.luis_vpc.id

  tags = {
    Name = "dev_public_rt"
  }

}
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.luis_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.luis_internet_gateway.id
}

resource "aws_route_table_association" "luis_public_association" {
  subnet_id      = aws_subnet.luis_public_subnet.id
  route_table_id = aws_route_table.luis_public_rt.id


}
resource "aws_security_group" "luis_sg" {
  name        = "luis_dev_sg"
  description = "this a security group for testing only, please do charge me for this lol"
  vpc_id      = aws_vpc.luis_vpc.id
  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks= ["0.0.0.0/0"]


  }
  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

#now we will create a ssh key and procced  to pair that with the AWS Keypar
#ssh-keygen -t ed25519

resource "aws_key_pair" "luis_key_pair"{
    key_name = "luis_key_pair"
    public_key = file("/home/luis/.ssh/luis_aws.pub")


}

resource "aws_instance" "luis_instance" { #here we use the AMI,we have query before using the datasource.tf file
    ami           = data.aws_ami.server_ami.id
    instance_type = "t2.micro"



    key_name = aws_key_pair.luis_key_pair.id #here we pair the key we have created before
    vpc_security_group_ids = [aws_security_group.luis_sg.id]
    subnet_id = aws_subnet.luis_public_subnet.id

    user_data = file("userdata.tpl") #user_data will help us to bootstrap our ec2 instance in order to install/execute some features or software we needed

    root_block_device { #ading few characteristics to the default volume store EBS that comes by default to the ec2 instance.
        volume_size = 10
    }
    tags = {
        Name = "testing_ec2"
    }

}