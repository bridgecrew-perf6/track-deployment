param(
    [parameter(Mandatory = $true)]
    [string]$sha,
    [parameter(Mandatory = $true)]
    [string]$repoUrl,
    [parameter(Mandatory = $true)]
    [string]$env,
    [parameter(Mandatory = $true)]
    [string]$vendorKey,
    [parameter(Mandatory = $false)]
    [DateTimeOffset]$deploymentDateTimeOffset
)

function Write-CloudWatchLog($currentTime, $sha, $repositoryUrl, $environment) {
    $message = @{
        Environment   = $environment
        Timestamp     = $currentTime
        HeadSha       = $sha
        RepositoryUrl = $repositoryUrl
    }

    $logEntry = New-Object -TypeName 'Amazon.CloudWatchLogs.Model.InputLogEvent'
    $logEntry.Message = ($message | ConvertTo-Json)
    $logEntry.Timestamp = (Get-Date).ToUniversalTime()

    $stream = Get-CWLLogStream -LogGroupName "DORASupportInfrastructureLogGroup" -LogStreamNamePrefix "GitHubLogStream"
    $response = Write-CWLLogEvent -SequenceToken $stream.UploadSequenceToken -LogGroupName "DORASupportInfrastructureLogGroup" -LogStreamName "GitHubLogStream" -LogEvent $logEntry
    
    Write-Host "Next Sequence Token" $response
}

function Write-LinearB($currentTimeInUnixSeconds, $sha, $repositoryUrl, $environment, $vendorKey) {
    if ($environment -ieq 'prod') {
        $environment = 'release' # linearb quirk
    }

    $uri = "https://public-api.linearb.io/api/v1/cycle-time-stages"
    $body = @{
        head_sha   = $sha
        repo_url   = $repositoryUrl
        stage_id   = $environment
        event_time = $currentTimeInUnixSeconds
    }

    Write-Host "LinearB Body: " ($body | Out-String)

    $response = Invoke-RestMethod -Method Post -Uri $uri -Header @{ "x-api-key" = $vendorKey; "Content-Type" = "application/json" } -Body ($Body | ConvertTo-Json)

    Write-Host $response
}

Import-Module AWS.Tools.CloudWatchLogs
$dateTime;
if ($deploymentDateTimeOffset) {
    $dateTime = $deploymentDateTimeOffset
}
else {
    $dateTime = [DateTimeOffset]::Now
}

try {    
    $currentTimeInUnixSeconds = $dateTime.ToUnixTimeSeconds()
    Write-Host "Logging to vendor"
    Write-LinearB $currentTimeInUnixSeconds $sha $repoUrl $env $vendorKey  
}
catch {
    Write-Host "Deploy Tracking Call To Vendor Failed"
    Write-Host $_
}

try {
    Write-Host "Logging to cloudwatch"
    $formattedDate = $dateTime.ToUniversalTime().ToString("o")
    Write-CloudWatchLog $formattedDate $sha $repoUrl $env
}
catch {
    Write-Host "Deploy Tracking Call To CloudWatch Failed"
    Write-Host $_
}
