resource "null_resource" "copy_files" {
  depends_on = [aws_instance.web]

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("clave.pem")
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("clave.pem")
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "file" {
    source      = "info.php"
    destination = "/tmp/info.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("clave.pem")
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "file" {
    source      = "submit.php"
    destination = "/tmp/submit.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("clave.pem")
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/script.sh",    # Dar permisos de ejecución al script
      "sudo /tmp/script.sh",             # Ejecutar el script de instalación
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo mv /tmp/info.php /var/www/html/info.php",
      "sudo mv /tmp/submit.php /var/www/html/submit.php"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("clave.pem")
      host        = aws_instance.web.public_ip
    }
  }
}
