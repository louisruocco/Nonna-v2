Function Azure-Login {
    $context = Get-AzContext
    if(!($context)){
        Connect-AzAccount
    }
}

function Update-OtherLearning {
    Azure-Login
}

Update-OtherLearning