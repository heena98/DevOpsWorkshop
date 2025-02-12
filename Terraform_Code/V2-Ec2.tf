provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-085ad6ae776d8f09c"
    instance_type = "t2.micro"
    security_groups = ["demo-sg"]
    
}

resource "aws_security_group" "demo-sg"{
    name = "demo-sg"
    description = "SSH Access"

    ingress {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


    tags = {
        Name = "ssh-port"
    }
}

