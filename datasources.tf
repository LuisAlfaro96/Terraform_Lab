data "aws_ami" "server_ami" { #a datasource its basically a query of the aws API to receive information  needed to deploy a resource, in this case an AMI to use later
    most_recent = true
    owners = ["099720109477"]
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]


    }

}
