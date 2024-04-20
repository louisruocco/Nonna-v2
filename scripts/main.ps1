function Get-BlobContents {
    param (
        [Parameter(Mandatory)]
        [string]$blob
    )

    $StorageAccountName = 'nonnastoracc'
    $ContainerName = 'nonnacontainer'
    $BlobFile = $blob
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey '<access key>'
    $container = Get-AzStorageContainer -Name $ContainerName -Context $context
    $client = $container.CloudBlobContainer.GetBlockBlobReference($blob)
    $file = $client.DownloadText()
    $file
}

Get-BlobContents -blob 'gym.txt'