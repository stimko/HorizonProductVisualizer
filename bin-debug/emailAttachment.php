<?php
require_once 'lib/swift_required.php';  
$image = file_get_contents("php://input"); //$_POST['encodedByteArray']; 
$attachment = Swift_Attachment::newInstance($image, 'submission.jpg', 'image/jpg'); 
//$emailTo = $_GET['emailTo'];
//$subject = $_GET['subject'];
//$from = $_GET['from'];
//$emailFrom = $_GET['emailFrom'];

$message = Swift_Message::newInstance()  
    /*Give the message a subject*/  
    ->setSubject('Yo')  
    /*Set the from address with an associative array*/  
    ->setFrom(array('s.w.timko@gmail.com'=>'Steve'))  
    /*Set the to addresses with an associative array*/  
    ->setTo(array('stimko@sigmagroup.com'))
    /*Give it a body*/  
    ->setBody('blah blah blah'); 
    $message->attach($attachment);  

    $transport = Swift_SendmailTransport::newInstance();  
    $mailer = Swift_Mailer::newInstance($transport);  
    $mailer->send($message);
?>