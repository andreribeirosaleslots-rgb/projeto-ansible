provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "host01" {
  ami                    = "ami-056244ee7f6e2feb8"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.secgroup.id]

  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"

  }
}

resource "aws_instance" "host02" {
  ami                    = "ami-056244ee7f6e2feb8"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.secgroup.id]
  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"

  }
}

resource "aws_instance" "host03" {
  ami                    = "ami-0b75f821522bcff85"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name #Debian 13
  vpc_security_group_ids = [aws_security_group.secgroup.id]
  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"

  }
}


resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-generated-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "ec2-generated-key.pem"
}

resource "aws_security_group" "secgroup" {

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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


output "host01_private_ip" {
  value = aws_instance.host01.private_ip
}

output "host02_private_ip" {
  value = aws_instance.host02.private_ip
}

output "host03_private_ip" {
  value = aws_instance.host03.private_ip
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}