terraform{
 required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

# configure aws provider
provider "aws" {
  region = "us-east-2"
  }

# Create VPCC
resource "aws_vpc" "MyLab-vpc" {
  cidr_block= var.cidr_block[0]

  tags = {
     Name = "MyLab-vpc"
  }

}

# Create Subnet (Public)
resource "aws_subnet" "MyLab-subnet1" {
  vpc_id = aws_vpc.MyLab-vpc.id
  cidr_block= var.cidr_block[1]

  tags = {
     Name = "MyLab-subnet1"
  }

}

# Create Internet gateway
resource "aws_internet_gateway" "MyLab-InternetGateway" {
  vpc_id = aws_vpc.MyLab-vpc.id


  tags = {
     Name = "MyLab-InternetGateway"
  }

}

# Create Security group
resource "aws_security_group" "MyLab-Sec-Group" {
  name = "MyLab Security Group"
  description = "Allow inbound and outbound traffic to MyLab"
  vpc_id = aws_vpc.MyLab-vpc.id

  dynamic ingress {
    iterator = port
    for_each = var.ports
    content {
           from_port = port.value
           to_port = port.value
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]

    }

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     Name = "allow traffic"
  }


}

#Create Route table and associations

resource "aws_route_table" "MyLab-RouteTable" {
  vpc_id = aws_vpc.MyLab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyLab-InternetGateway.id
  }
  tags = {
     Name = "MyLab-RouteTable"
  }

}

resource "aws_route_table_association" "MyLab-association" {
  subnet_id = aws_subnet.MyLab-subnet1.id
  route_table_id = aws_route_table.MyLab-RouteTable.id

}

# Create an EC2 instance for jenkins server
resource "aws_instance" "Jenkins" {
  ami           =  var.ami
  instance_type = var.instance_type
  key_name = "mylab-demo"
  vpc_security_group_ids = [aws_security_group.MyLab-Sec-Group.id]
  subnet_id = aws_subnet.MyLab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./installjenkins.sh")


  tags = {
    Name = "Jenkins-server"
  }
}

# Create Ec2 instance to host the Ansible control node
resource "aws_instance" "Ansible-ControlNode" {
  ami           =  var.ami
  instance_type = var.instance_type
  key_name = "mylab-demo"
  vpc_security_group_ids = [aws_security_group.MyLab-Sec-Group.id]
  subnet_id = aws_subnet.MyLab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallAnsibleCN.sh")


  tags = {
    Name = "Ansible-ControlNode"
  }
}

# Create Ec2 instance to host the Ansible Managed Node & apache-tomcat
resource "aws_instance" "Ansible-ManagedNode" {
  ami           =  var.ami
  instance_type = var.instance_type
  key_name = "mylab-demo"
  vpc_security_group_ids = [aws_security_group.MyLab-Sec-Group.id]
  subnet_id = aws_subnet.MyLab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./AnsibleManagedNode.sh")


  tags = {
    Name = "AnsibleMN-ApacheTomcat"
  }
}

# Create Ec2 instance to host the Ansible Managed Node & Docker host
resource "aws_instance" "Docker-host" {
  ami           =  var.ami
  instance_type = var.instance_type
  key_name = "mylab-demo"
  vpc_security_group_ids = [aws_security_group.MyLab-Sec-Group.id]
  subnet_id = aws_subnet.MyLab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Docker.sh")


  tags = {
    Name = "Docker-host"
  }
}

# Create Ec2 instance to host Nexus
resource "aws_instance" "Nexus" {
  ami           =  var.ami
  instance_type = var.instance_type_for_nexus
  key_name = "mylab-demo"
  vpc_security_group_ids = [aws_security_group.MyLab-Sec-Group.id]
  subnet_id = aws_subnet.MyLab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallNexus.sh")


  tags = {
    Name = "Nexus-host"
  }
}
