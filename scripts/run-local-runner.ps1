# Setup and register a GitHub Actions self-hosted runner (Windows).
# Requires GITHUB_PAT in environment (Personal Access Token with repo scope)
# to obtain the registration token. Optional parameters: RepoUrl, RunnerName, Labels.
#
# Usage:
#   $env:GITHUB_PAT = "ghp_xxxx"
#   .\run-local-runner.ps1
#   .\run-local-runner.ps1 -RepoUrl "https://github.com/your-org/your-infra-repo"
#
# Default repository: https://github.com/ndochp/Multitool.infra.GitHub

param(
    [string] $RepoUrl = "https://github.com/ndochp/Multitool.infra.GitHub",
    [string] $RunnerName = "local-runner",
    [string] $Labels = "self-hosted,windows"
)

$RunnerDir = if ($env:RUNNER_DIR) { $env:RUNNER_DIR } else { "actions-runner" }

if (-not $env:GITHUB_PAT) {
    Write-Error "GITHUB_PAT is not set. Set it to a Personal Access Token (repo scope) to get the registration token. Example: `$env:GITHUB_PAT = 'ghp_xxxx'"
    exit 1
}

Write-Host "Setting up GitHub Actions runner for $RepoUrl"

if (-Not (Test-Path $RunnerDir)) {
    New-Item -ItemType Directory -Path $RunnerDir | Out-Null
}
Set-Location $RunnerDir

if (-Not (Test-Path ".\config.cmd")) {
    Write-Host "Downloading latest GitHub Actions runner..."
    $runnerVersion = (Invoke-RestMethod https://api.github.com/repos/actions/runner/releases/latest).tag_name
    $versionNum = $runnerVersion.TrimStart('v')
    $runnerZip = "actions-runner-win-x64-$versionNum.zip"
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/$runnerVersion/$runnerZip" -OutFile $runnerZip -UseBasicParsing
    Expand-Archive -Path $runnerZip -DestinationPath . -Force
}

$apiUrl = $RepoUrl -replace "https://github.com/", "https://api.github.com/repos/"
$apiUrl = $apiUrl -replace "\.git$", ""
$regToken = (Invoke-RestMethod -Headers @{ Authorization = "token $env:GITHUB_PAT" } -Method Post -Uri "$apiUrl/actions/runners/registration-token").token

.\config.cmd --url $RepoUrl --token $regToken --name $RunnerName --labels $Labels --unattended

Write-Host "Starting the runner..."
& .\run.cmd
