<?php
$name = 'Dude';
$email = 'stimko@sigmagroup.com';

$to = '$name <$email>';

//$encodedString = $_POST['encodedString'];

$from = 'John-Smith ';

$subject = 'Here is your attachment';

$message = 'the message';

//$fileatt = “./test.pdf”;

$fileatttype = 'application/jpg';

$fileattname = 'newimage.jpg';

$headers = 'From: $from';

//$file = fopen($fileatt, ‘rb’);

//$data = fread($file, filesize($fileatt));

//fclose($file);

/*$semi_rand = md5(time());

$mime_boundary = '==Multipart_Boundary_x{$semi_rand}x';

$headers .= '\nMIME-Version: 1.0\n' .

'Content-Type: multipart/mixed;\n' .

' boundary=\'{$mime_boundary}\'';

$message = 'This is a multi-part message in MIME format.\n\n' .

'-{$mime_boundary}\n' .

'Content-Type: text/plain; charset=\”iso-8859-1\n' .

'Content-Transfer-Encoding: 7bit\n\n' .

$message .= '\n\n';

$data = chunk_split($encodedString);

$message .= '–{$mime_boundary}\n' .

'Content-Type: {$fileatttype};\n' .

' name=\'{$fileattname}\'\n' .

'Content-Disposition: attachment;\n' .

' filename=\'{$fileattname}\'\n' .

'Content-Transfer-Encoding: base64\n\n' .

$data . '\n\n' .

'-{$mime_boundary}-\n';*/

if(@mail($email, $subject, $message)) {

echo '

The email was sent.

';

}
else {
echo '


There was an error sending the mail.

';

}
?>