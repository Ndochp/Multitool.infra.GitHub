# This script sets up and runs a GitHub Actions runner on Windows

param(
    [string]$RepoUrl = "https://github.com/OWNER/REPO",
    [string]$RunnerName = "local-runner",
    [string]$Labels = "self-hosted,windows"
)

$RunnerDir = "actions-runner"

Write-Host "Setting up GitHub Actions runner for $RepoUrl"

if (-Not (Test-Path $RunnerDir)) {
    New-Item -ItemType Directory -Path $RunnerDir | Out-Null
    Set-Location $RunnerDir
    Write-Host "Downloading latest GitHub Actions runner..."
    $runnerVersion = (Invoke-RestMethod https://api.github.com/repos/actions/runner/releases/latest).tag_name
    $runnerZip = "actions-runner-win-x64-$($runnerVersion.TrimStart('v')).zip"
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/$runnerVersion/$runnerZip" -OutFile $runnerZip
    Expand-Archive -Path $runnerZip -DestinationPath .
} else {
    Set-Location $RunnerDir
}

if (-not $env:GITHUB_PAT) {
    $GITHUB_PAT = Read-Host -Prompt "Enter your GitHub Personal Access Token"
} else {
    $GITHUB_PAT = $env:GITHUB_PAT
}

$apiUrl = $RepoUrl -replace "https://github.com/", "https://api.github.com/repos/"
$regToken = (Invoke-RestMethod -Headers @{Authorization = "token $GITHUB_PAT"} -Method Post -Uri "$apiUrl/actions/runners/registration-token").token

.\config.cmd --url $RepoUrl --token $regToken --name $RunnerName --labels $Labels --unattended

Write-Host "Starting the runner..."
Start-Process -NoNewWindow