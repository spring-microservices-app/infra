
resource "aws_security_group" "user_sg" {
  name        = "user-service-sg"
  description = "Allow gRPC (9090), Rest (8082), SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Eureka Server port"
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Rest API for Stock Service"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Rest API for User Service"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "gRPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "user-service-sg"
  }
}

resource "aws_instance" "user_service" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.user_sg.id]


  user_data = templatefile("${path.module}/user-service.sh.tpl", {
    JAR_URL       = var.user_service_jar_url,
    MONGODB_URI   = var.mongodb_uri,
    MONGODB_DATABASE = var.mongodb_database,
    EUREKA_URL    = var.eureka_url
  })

  tags = {
    Name = "user-service"
  }

    iam_instance_profile = aws_iam_instance_profile.user_instance_profile.name

}

resource "aws_eip" "user_eip" {
  instance = aws_instance.user_service.id
}

resource "aws_iam_role" "user_ec2_role" {
  name = "user-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy" "user_s3_read_policy" {
  name = "user-service-s3-read"
  role = aws_iam_role.user_ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = "arn:aws:s3:::my-jar-repository/*"
    }]
  })
}

resource "aws_iam_instance_profile" "user_instance_profile" {
  name = "user-service-profile"
  role = aws_iam_role.user_ec2_role.name
}
