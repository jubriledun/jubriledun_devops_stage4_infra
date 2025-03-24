# Terraform Configuration for Infrastructure Provisioning

provider "aws" {
  region = "us-east-1" # Change as per your region
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "devops_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "devops_sg" {
  vpc_id = aws_vpc.devops_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_server" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with your AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.devops_subnet.id
  security_groups        = [aws_security_group.devops_sg.name]
  key_name               = "your-key-pair"
  
  tags = {
    Name = "DevOps-Stage-4-Server"
  }
}

resource "null_resource" "provisioner" {
  depends_on = [aws_instance.devops_server]

  provisioner "local-exec" {
    command = "echo '[devops] \n${aws_instance.devops_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem' > inventory.ini"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml"
  }
}
