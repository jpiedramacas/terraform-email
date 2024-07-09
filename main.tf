# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# Grupo de Seguridad para EC2
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Recurso EC2
resource "aws_instance" "web" {
  ami           = "ami-08a0d1e16fc3f61ea" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "vockey"  # Aquí se define directamente el nombre del par de claves
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebServerFuntions"
  }

  # Conexión SSH
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("clave.pem")  # Se usa directamente el archivo de clave privada
    host        = self.public_ip
  }
}

# Tópico SNS
resource "aws_sns_topic" "sns_topic" {
  name = "webserver-topic"
}

# Suscripción al Tópico SNS
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "geovanny.piedra@tajamar365.com"
}
