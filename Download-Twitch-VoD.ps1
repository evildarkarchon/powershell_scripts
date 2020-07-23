[CmdletBinding()]
param (
    [string]$ConfigFile="z:\Videos\480p.conf",
    [string]$IntermediateDir="D:\Video Downloads",
    [Parameter(Mandatory=$true)]
    [string]$Streamer,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousDirectory = Get-Location
Set-Location $IntermediateDir

if (-not (Test-Path -PathType Any "Z:\Videos\Twitch\$($Streamer)")) { 
    New-Item -ItemType Directory -Path "Z:\Videos\Twitch\$($Streamer)"
    New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt"
    (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt").Attributes += "Hidden"
    New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt"
    (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt").Attributes += "Hidden"
}

youtube-dl --config-location $ConfigFile --download-archive "z:\Videos\Twitch\$($Streamer)\downloaded.txt" $Urls

foreach ($file in Get-ChildItem $IntermediateDir) {
    Write-Host "Moving '$($file.Name)' to 'Z:\Videos\Twitch\$($Streamer)\$($file.Name)'"
    Move-item -Path $file.Name -Destination "z:\Videos\Twitch\$($Streamer)\$($file.Name)"
}
Set-Location $PreviousDirectory