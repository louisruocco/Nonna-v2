Connect-AzAccount
function Get-BlobContents {
    param (
        [Parameter(Mandatory)]
        [string]$blob
    )

    $sasToken = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'token' -AsPlainText

    $StorageAccountName = 'nonnastoracc'
    $ContainerName = 'nonnacontainer'
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -SasToken $sasToken
    $container = Get-AzStorageContainer -Name $ContainerName -Context $context
    $client = $container.CloudBlobContainer.GetBlockBlobReference($blob)
    $file = $client.DownloadText()
    $file
}

Function Randomise { 
    param (
        [array] $category
    )

    return $category | Sort-Object{Get-Random}
}

$apiKey = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'youtubeAPIKey' -AsPlainText
$topic = Get-BlobContents -blob 'other learning.txt'
$endpoint = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelType=any&q=$topic&key=$apiKey"
$res = Invoke-RestMethod $endpoint
$items = $res.items
$links = foreach($item in $items){
    $titles = $item.snippet.title
    $urls = $item.id.videoId
    $table = @{ $titles = $urls }
    foreach($thing in $table){
        $keys = $thing.Keys
        $values = $thing.Values
        "$keys | <a href = 'https://www.youtube.com/watch?v=$values'>https://www.youtube.com/watch?v=$values</a>"
    }
}
function Send-Email {
    $learning = Get-BlobContents -blob 'other learning.txt'
    $randomiser = Get-BlobContents -blob 'questions.txt'
    
    $username = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'username' -AsPlainText
    $emailAddress = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'email-address' -AsPlainText
    $password = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'password' -AsPlainText | ConvertTo-SecureString -AsPlainText -Force
    
    $randomise = $randomiser | Sort-Object{Get-Random}
    $splitLines = $randomise -split "`n"
    $questions = $splitLines[0..11]
    $results = foreach($question in $questions){
        "<li>$question</li>"
    }

    $youtubeLinks = foreach ($link in $links){
        "<li>$link</li>"
    }

    $body = @"
    <h1>Nonna</h1>
    <p>Hi Lou, Remember that I am always watching over you. Have a great day!. Love Nonna</p>
    <h2>DP-300 Questions</h2>
    <ul>
        $results
    </ul>
    <h2>Learning Topic of the Week</h2>
    <ul>
        <li>$learning</li>
    </ul>
    <h2>This Week's Learning Resources:</h2>
        <ul>
            $youtubeLinks
        </ul>
"@

    $email = @{
        from = $username
        to = $emailAddress
        subject = "Nonna"
        smtpserver = "smtp.gmail.com"
        body = $body
        port = 587
        credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
        usessl = $true
        verbose = $true
    }

    Send-MailMessage @email -BodyAsHtml
}

Send-Email