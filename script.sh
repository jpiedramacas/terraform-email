#!/bin/bash

# Actualizar la instancia EC2
sudo yum update -y && sudo yum upgrade -y

# Instalar el servidor web Apache
sudo yum install httpd -y

# Iniciar el servidor web Apache
sudo service httpd start

# Configurar el servidor web Apache para iniciar en el arranque
sudo chkconfig httpd on

# Navegar al directorio raíz del servidor web
cd /var/www/html

# Instalar PHP y algunas extensiones necesarias
sudo yum install php php-cli php-json php-mbstring -y

# Instalar Composer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo php -r "unlink('composer-setup.php');"

# Instalar el SDK de AWS usando Composer
cd ~
composer require aws/aws-sdk-php --no-interaction

# Copiar los archivos al directorio raíz del servidor web
sudo mv ~/vendor /var/www/html/

# Reiniciar el servicio Apache para aplicar los cambios
sudo systemctl restart httpd
sudo systemctl enable httpd

# Reiniciar y habilitar el servicio PHP-FPM
sudo systemctl restart php-fpm
sudo systemctl enable php-fpm
