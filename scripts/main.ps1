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
    $gym = Get-BlobContents -blob 'gym.txt'
    $learning = Get-BlobContents -blob 'other learning.txt'
    $meals = Get-BlobContents -blob 'meal-planner.txt'
    $exercises = $gym -split ';'
    $mealPlan = $meals -split ';'

    $username = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'username' -AsPlainText
    $emailAddress = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'email-address' -AsPlainText
    $password = Get-AzKeyVaultSecret -VaultName 'nonna-kv' -Name 'password' -AsPlainText | ConvertTo-SecureString -AsPlainText -Force
    
    $mealPlanner = Randomise -category $mealPlan
    $exercises = Randomise -category $gym

    $lunch = $mealPlanner[0]
    $dinner = $mealPlanner[1]

    $day = (Get-Date).DayOfWeek

    if($day -eq "Tuesday" -or $day -eq "Thursday"){
        $array = $exercises[0..7]
        $gymExercises = foreach($exercise in $array){
            "<li>$exercise</li>"
        }
    } else {
        $gymExercises = "<h3>No Gym Today<h3>"
    }

    $youtubeLinks = foreach ($link in $links){
        "<li>$link</li>"
    }

    $body = @"
    <h1>Nonna</h1>
    <p>Hi Lou, Remember that I am always watching over you. Have a great day!. Love Nonna</p>
    <h2>Learning Topic of the Week</h2>
    <ul>
        <li>$learning</li>
    </ul>
    <h2>This Week's Learning Resources:</h2>
        <ul>
            $youtubeLinks
        </ul>
    <h2>Today's Gym Session</h2>
    <hr>
    <ul>
        $gymexercises
    </ul>
    <h2>Today's Meal Plan</h2>
    <hr>
    <h3>Lunch: $Lunch</h3>
    <h3>Dinner: $dinner </h3>
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