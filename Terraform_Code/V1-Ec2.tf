provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-085ad6ae776d8f09c"
    instance_type = "t2.micro"
}