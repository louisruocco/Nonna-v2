Function Check-AzureSession {
    $context = Get-AzContext
    if(!($context)){
        Connect-AzAccount
    }
}

function Update-LearningTopic {
    Check-AzureSession
    $kvparams = @{
        VaultName = "nonna-kv"
        Name = "token"
    }

    $sacontextparams = @{
        StorageAccountName = "nonnastoracc"
        SasToken = Get-AzKeyVaultSecret @kvparams -AsPlainText
    }

    $sacontext = New-AzStorageContext @sacontextparams

    $blobcontentparams = @{
        Context = $sacontext
        Container = "nonnacontainer"
        Blob = "other learning.txt"
        Destination = "C:\Nonna\Learning"
    }
    Write-output "Downloading other learning text document for editing"
    Get-AzStorageBlobContent @blobcontentparams
    cls
    $value = Read-Host -Prompt "Update Learning Topic Here"
    $value
}

Update-LearningTopic