<?php 
require 'vendor/autoload.php';

use Aws\Sns\SnsClient; 
use Aws\Exception\AwsException;

if ($_SERVER["REQUEST_METHOD"] == "POST") { 
    $name = $_POST["name"]; 
    $email = $_POST["email"]; 
    $message = $_POST["message"]; 

    // Reemplaza 'your-sns-topic-arn' con el ARN de tu tópico SNS
    $snsTopicArn = 'arn:aws:sns:us-east-1:533266991023:webserver-topic'; 

    // Inicializa el cliente SNS
    $snsClient = new SnsClient([ 
        'version' => 'latest', 
        'region' => 'us-east-1' // Reemplaza con tu región de AWS
    ]); 

    // Crea el mensaje para enviar al tópico SNS
    $messageToSend = json_encode([ 
        'email' => $email, 
        'name' => $name, 
        'message' => $message 
    ]); 

    try { 
        // Publica el mensaje en el tópico SNS
        $snsClient->publish([ 
            'TopicArn' => $snsTopicArn, 
            'Message' => $messageToSend 
        ]); 

        echo "Message sent successfully."; 
    } catch (AwsException $e) { 
        echo "Error sending message: " . $e->getMessage(); 
    } 
} else { 
    http_response_code(405); 
    echo "Method Not Allowed"; 
} 
?>
