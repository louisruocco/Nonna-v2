function Get-BlobContents {
    param (
        [Parameter(Mandatory)]
        [string]$blob
    )

    $StorageAccountName = 'nonnastoracc'
    $ContainerName = 'nonnacontainer'
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey '<access key>'
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

function Send-Email {
    $gym = Get-BlobContents -blob 'gym.txt'
    $learning = Get-BlobContents -blob 'other learning.txt'
    $meals = Get-BlobContents -blob 'meal-planner.txt'
    $secrets = Get-BlobContents -blob 'secrets.txt'
    $secret = $secrets -split ';'
    $exercises = $gym -split ';'
    $mealPlan = $meals -split ';'

    $username = $secret[0]
    $password = $secret[1] | ConvertTo-SecureString -AsPlainText -Force
    $emailAddress = $secret[2]
    
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

    $learningLinks = foreach ($item in $learning){
        "<li>$item</li>"
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
            $learningLinks
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