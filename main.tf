provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "default" {
  name        = "default"
  description = "Default security group"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.medusa_instance.public_ip}/32"]  # Use the output value for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "medusa_instance" {
  ami           = "ami-0e86e20dae9224db8"  # Example AMI ID, modify as needed
  instance_type = "t2.small"
  security_groups = [aws_security_group.default.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              # Docker setup (assuming files are uploaded later)
              # For demo purposes, we're not including docker load and docker-compose up commands here.
              EOF

  tags = {
    Name = "MedusaAppInstance"
  }
}

output "instance_public_ip" {
  value = aws_instance.medusa_instance.public_ip
}
