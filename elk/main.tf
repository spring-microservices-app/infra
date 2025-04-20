resource "aws_security_group" "elk_sg" {
  name        = "elk-sg"
  description = "Allow SSH, HTTP, Kibana, Elasticsearch and Logstash"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Elasticsearch"
    from_port   = 9200
    to_port     = 9200
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

resource "aws_instance" "elk" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.elk_sg.id]

  associate_public_ip_address = true # required when assigning EIP in a default VPC
  user_data                   = base64encode(templatefile("${path.module}/setup.sh.tpl", {}))

  
  root_block_device {
    volume_size = 15
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "elk-server"
  }
}

# Associate existing EIP (replace with your EIP allocation ID)
resource "aws_eip_association" "elk_eip" {
  instance_id   = aws_instance.elk.id
  allocation_id = var.public_elastic_ip_allocation_id  
}

