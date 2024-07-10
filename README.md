# Proyecto EC2 con SNS y Formulario PHP

## Tabla de Contenidos
1. [Pasos Manuales Añadir Rol a la EC2](#pasos-manuales-añadir-rol-a-la-ec2)
2. [Explicación de cada archivo de configuración](#explicacion-de-cada-archivo-de-configuracion)
3. [Funcionamiento del sistema](#funcionamiento-del-sistema)

## Pasos Manuales Añadir Rol a la EC2

### 1. Añadir Rol a la EC2
1. Ir a la consola de Amazon EC2.
2. Seleccionar la instancia EC2 a la que desea añadir el rol.
3. Ir a "Acciones" -> "Seguridad" -> "Modificar rol de IAM".
4. Elegir el rol “LabRol”.
5. Guardar los cambios.

### 2. Añadir Política al Rol en IAM
1. Ir a la consola de Amazon IAM.
2. Buscar el rol “LabRol”.
3. Seleccionar el rol y ir a "Agregar permisos".
4. Añadir la política “AmazonSNSFullAccess”.
5. Guardar los cambios.

### 3. Configuración SNS con Terraform
1. Ejecutar `terraform apply` para desplegar la infraestructura.
2. Tomar nota del output de Terraform, específicamente el ARN del SNS.
3. Colocar el ARN del SNS en el archivo `submit.php`.
4. Revisar el correo electrónico y aceptar la suscripción al SNS.

## Explicación de cada archivo de configuración

### Estructura del Proyecto
```
├── clave.pem
├── index.html
├── info.php
├── main.tf
├── outputs.tf
├── provisioners.tf
├── script.sh
└── submit.php
```

### Archivos Detallados

- **clave.pem**
  - Archivo de clave privada para acceder a la instancia EC2 vía SSH.
  - **Uso:** Guardar de manera segura y utilizar con el comando SSH para conectarse a la instancia.

- **index.html**
  - Página principal del sitio web.
  - **Uso:** Interfaz del usuario donde se encuentra el formulario para enviar un mensaje.

- **info.php**
  - Archivo PHP que muestra información del sistema PHP instalado.
  - **Uso:** Verificar la correcta instalación y configuración de PHP en el servidor.

- **main.tf**
  - Archivo principal de configuración de Terraform.
  - **Uso:** Define los recursos de infraestructura, como la instancia EC2, roles de IAM, y SNS.

- **outputs.tf**
  - Archivo de Terraform que define los outputs del despliegue.
  - **Uso:** Muestra información útil después de ejecutar `terraform apply`, como el ARN del SNS.

- **provisioners.tf**
  - Archivo de Terraform que contiene provisionadores.
  - **Uso:** Configura la instancia EC2 después de su creación, como instalar software necesario.

- **script.sh**
  - Script de shell para configurar el servidor.
  - **Uso:** Ejecutado por el provisionador de Terraform para instalar y configurar dependencias en la EC2.

- **submit.php**
  - Archivo PHP que maneja el envío del formulario y publica mensajes a SNS.
  - **Uso:** Procesa la información del formulario y envía una notificación a SNS.

## Funcionamiento del Sistema

El sistema está diseñado para que un formulario en una página web envíe un mensaje a un servicio de Amazon SNS, que luego notifica a los suscriptores vía correo electrónico. Aquí está el flujo de trabajo detallado:

1. **Usuario Interactúa con la Página Web:**
   - El usuario accede a `index.html` y completa el formulario.

2. **Formulario Envía Datos a `submit.php`:**
   - El formulario envía una solicitud POST a `submit.php`.

3. **Procesamiento en `submit.php`:**
   - El archivo `submit.php` recibe los datos del formulario.
   - Utiliza el ARN del SNS configurado para publicar un mensaje en el tema SNS.

4. **SNS Envía Notificación:**
   - SNS recibe el mensaje y envía una notificación a todos los suscriptores del tema.
   - Los suscriptores reciben la notificación en sus correos electrónicos.

5. **Aceptación de Suscripción:**
   - Inicialmente, los usuarios deben aceptar la suscripción al tema SNS desde su correo electrónico.

6. **Terraform y Provisionamiento:**
   - `main.tf` define la infraestructura necesaria y la configura.
   - `script.sh` instala las dependencias necesarias en la instancia EC2.
   - `outputs.tf` proporciona el ARN del SNS necesario para `submit.php`.

### Conexiones y Comunicaciones
- **Formulario y `submit.php`:**
  - El formulario en `index.html` se comunica con `submit.php` a través de una solicitud HTTP POST.
  
- **`submit.php` y SNS:**
  - `submit.php` utiliza las credenciales del rol IAM para publicar en el tema SNS.
  
- **SNS y Correo Electrónico:**
  - SNS envía mensajes a las direcciones de correo electrónico suscritas al tema.

Este flujo asegura que los mensajes enviados desde el formulario web sean entregados a los usuarios mediante notificaciones por correo electrónico, utilizando la infraestructura segura y escalable proporcionada por AWS.
