
resource "aws_security_group" "stock_sg" {
  name        = "stock-service-sg"
  description = "Allow gRPC (9090), Eureka (8081), SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Eureka"
    from_port   = 8081
    to_port     = 8081
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
    Name = "stock-service-sg"
  }
}

resource "aws_instance" "stock_service" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.stock_sg.id]

  user_data = templatefile("${path.module}/stock-service.sh.tpl", {
    JAR_URL       = var.stock_service_jar_url,
    MONGODB_URI   = var.mongodb_uri,
    MONGODB_DATABASE = var.mongodb_database,
    EUREKA_URL    = var.eureka_url
  })

  tags = {
    Name = "stock-service"
  }

    iam_instance_profile = aws_iam_instance_profile.stock_instance_profile.name

}

resource "aws_eip" "stock_eip" {
  instance = aws_instance.stock_service.id
}

resource "aws_iam_role" "stock_ec2_role" {
  name = "stock-service-role"

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


resource "aws_iam_role_policy" "stock_s3_read_policy" {
  name = "stock-service-s3-read"
  role = aws_iam_role.stock_ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = "arn:aws:s3:::my-jar-repository/*"
    }]
  })
}

resource "aws_iam_instance_profile" "stock_instance_profile" {
  name = "stock-service-profile"
  role = aws_iam_role.stock_ec2_role.name
}
