[Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$vault = New-Object Windows.Security.Credentials.PasswordVault
$StoredCredential = $creds.where({$_.Resource -eq "Azure Sub"})
$subscriptionID = $StoredCredential.Password

Connect-AzAccount

Set-AzContext -Subscription $subscriptionID