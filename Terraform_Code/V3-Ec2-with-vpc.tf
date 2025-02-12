# Define the AWS provider and specify the region
provider "aws" {
    region = "us-east-1"
}

# Create an EC2 instance with a specified AMI and instance type
resource "aws_instance" "demo-server" {
    ami = "ami-085ad6ae776d8f09c"  # Amazon Machine Image (AMI) ID
    instance_type = "t2.micro"  # Instance type (eligible for free tier)
    security_groups = [aws_security_group.demo-sg.name]  # Attach security group
    subnet_id = aws_subnet.dpp-public-subnet-01.id  # Place instance in a specific subnet
}

# Create a Security Group to allow SSH access
resource "aws_security_group" "demo-sg" {
    name = "demo-sg"  # Security group name
    description = "SSH Access"  # Description of the security group
    vpc_id = aws_vpc.dpp-vpc.id  # Attach to the specified VPC

    # Define inbound rules (ingress) to allow SSH access
    ingress {
        description = "SSH access"  # Description of the rule
        from_port = 22  # Allow incoming traffic on port 22 (SSH)
        to_port = 22
        protocol = "tcp"  # TCP protocol
        cidr_blocks = ["0.0.0.0/0"]  # Open to all IP addresses (not recommended for production)
    }

    # Define outbound rules (egress) to allow all traffic out
    egress {
        from_port = 0  # Allow outgoing traffic from all ports
        to_port = 0
        protocol = "-1"  # Allow all protocols
        cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to any destination
    }

    # Tag the security group
    tags = {
        Name = "ssh-port"
    }
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "dpp-vpc" {
    cidr_block = "10.1.0.0/16"  # Define the IP range of the VPC
    tags = {
        Name = "dpp-vpc"  # Name tag for identification
    }
}

# Create a public subnet in availability zone us-east-1a
resource "aws_subnet" "dpp-public-subnet-01" {
    vpc_id = aws_vpc.dpp-vpc.id  # Associate subnet with VPC
    cidr_block = "10.1.1.0/24"  # Define subnet IP range
    map_public_ip_on_launch = true  # Assign public IP to instances automatically
    availability_zone = "us-east-1a"  # Specify AZ for subnet
    tags = {
        Name = "dpp-public-subnet-01"
    }
}

# Create another public subnet in availability zone us-east-1b
resource "aws_subnet" "dpp-public-subnet-02" {
    vpc_id = aws_vpc.dpp-vpc.id  # Associate subnet with VPC
    cidr_block = "10.1.2.0/24"  # Define subnet IP range
    map_public_ip_on_launch = true  # Assign public IP to instances automatically
    availability_zone = "us-east-1b"  # Specify AZ for subnet
    tags = {
        Name = "dpp-public-subnet-02"
    }
}

# Create an Internet Gateway for internet access
resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id  # Attach IGW to the VPC
    tags = {
        Name = "dpp-igw"
    }
}

# Create a Route Table for public subnets
resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id  # Associate route table with VPC

    # Define a route that directs all outbound traffic to the internet gateway
    route {
        cidr_block = "0.0.0.0/0"  # Default route for internet traffic
        gateway_id = aws_internet_gateway.dpp-igw.id  # Use IGW as the gateway
    }
}

# Associate the public subnet-01 with the route table
resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
    subnet_id = aws_subnet.dpp-public-subnet-01.id  # Specify the subnet
    route_table_id = aws_route_table.dpp-public-rt.id  # Attach to route table
}

# Associate the public subnet-02 with the route table
resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
    subnet_id = aws_subnet.dpp-public-subnet-02.id  # Specify the subnet
    route_table_id = aws_route_table.dpp-public-rt.id  # Attach to route table
}
