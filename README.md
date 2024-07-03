

## Configuración del Entorno Cloud9

### Paso 1: Crear un Entorno Cloud9

1. Inicia sesión en la consola de AWS y navega a **Cloud9**.
2. Haz clic en **Create environment**.
3. Proporciona un nombre y una descripción para tu entorno, luego haz clic en **Next step**.
4. Selecciona **Create a new EC2 instance for environment (direct access)**.
5. Elige un tipo de instancia **t2.micro** para mantenerse dentro del Free Tier.
6. Configura el resto de opciones según tus necesidades y haz clic en **Next step**, luego en **Create environment**.

### Paso 2: Configurar Cloud9 para Terraform

1. Una vez que el entorno esté listo, abre el terminal.
2. Instala Terraform ejecutando los siguientes comandos:

```sh
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```

## Configuración de Terraform

### Estructura de Archivos

Crea un nuevo directorio para tu proyecto y organiza los archivos de la siguiente manera:

```
my-portfolio
├── main.tf
├── variables.tf
├── outputs.tf
└── userdata.sh
```

### Archivo `variables.tf`

Define las variables necesarias para tu configuración de Terraform.

```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
```

### Archivo `outputs.tf`

Define los outputs para obtener información después de la ejecución de Terraform.

```hcl
output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}
```

### Archivo `userdata.sh`

Este script se ejecutará al inicio de la instancia EC2 para instalar Apache, PHP y configurar el servidor.

```sh
#!/bin/bash
yum update -y
yum install -y httpd php php-cli php-json php-mbstring
service httpd start
chkconfig httpd on

cd /var/www/html
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
php composer.phar require aws/aws-sdk-php

# Create a sample HTML form and PHP script
cat <<EOL > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Contact Form</title>
</head>
<body>
<h1>Contact Form</h1>
<form action="submit.php" method="POST">
<label for="name">Name:</label><br>
<input type="text" id="name" name="name" required><br>
<label for="email">Email:</label><br>
<input type="email" id="email" name="email" required><br>
<label for="message">Message:</label><br>
<textarea id="message" name="message" rows="4" required></textarea><br>
<input type="submit" value="Submit">
</form>
</body>
</html>
EOL

cat <<EOL > /var/www/html/submit.php
<?php
require 'vendor/autoload.php';
use Aws\Sns\SnsClient;
use Aws\Exception\AwsException;

if (\$_SERVER["REQUEST_METHOD"] == "POST") {
  \$name = \$_POST["name"];
  \$email = \$_POST["email"];
  \$message = \$_POST["message"];

  \$snsTopicArn = 'arn:aws:sns:us-east-1:XXXXXXX:test'; // Replace with your SNS topic ARN
  \$snsClient = new SnsClient([
    'version' => 'latest',
    'region' => 'us-east-1'
  ]);

  \$messageToSend = json_encode([
    'email' => \$email,
    'name' => \$name,
    'message' => \$message
  ]);

  try {
    \$snsClient->publish([
      'TopicArn' => \$snsTopicArn,
      'Message' => \$messageToSend
    ]);
    echo "Message sent successfully.";
  } catch (AwsException \$e) {
    echo "Error sending message: " . \$e->getMessage();
  }
} else {
  http_response_code(405);
  echo "Method Not Allowed";
}
?>
EOL

service httpd restart
```

### Archivo `main.tf`

Define los recursos de AWS para tu configuración.

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # AMI de Amazon Linux 2
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  user_data = file("userdata.sh")

  tags = {
    Name = "PortafolioWebServer"
  }

  security_group {
    description = "Allow HTTP and SSH"
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
}

resource "aws_sns_topic" "sns_topic" {
  name = "VisitorNotifications"
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "tu_email@example.com"  # Reemplaza con tu dirección de email
}
```

## Desplegar con Terraform

### Paso 1: Inicializar Terraform

1. Abre una terminal en tu entorno Cloud9.
2. Navega al directorio de tu proyecto.
3. Inicializa Terraform.

```sh
terraform init
```

### Paso 2: Aplicar la Configuración de Terraform

1. Revisa el plan de Terraform para asegurarte de que todos los recursos se crearán según lo esperado.

```sh
terraform plan
```

2. Aplica la configuración de Terraform.

```sh
terraform apply
```

3. Confirma la ejecución escribiendo `yes` cuando se te pida.

### Paso 3: Verificar el Despliegue

1. Obtén la dirección IP pública de la instancia EC2 desde la salida de Terraform o desde la consola de AWS.
2. Abre un navegador web y navega a la dirección IP pública de tu instancia EC2.
3. Deberías ver el formulario HTML. Completa y envía el formulario para probar la funcionalidad.
