[CmdletBinding(DefaultParameterSetName="Download")]
param (
    [Parameter(ParameterSetName="Download")]
    [string]$Quality="480p",
    [Parameter(ParameterSetName="Download")]
    [string]$IntermediateDir="D:\Video Downloads",
    [Parameter(ParameterSetName="Download")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Parameter(ParameterSetName="Download")]
    [Parameter(Mandatory=$true)]
    [string]$Streamer,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousDirectory = Get-Location
try {
    if ($ListFormats) {
        youtube-dl --list-formats $Urls
    }
    else {
        if (-not (Test-Path -PathType Any $IntermediateDir)) {
            New-Item -ItemType Directory -Path $IntermediateDir -Force
        }
        Set-Location $IntermediateDir
    
        if (-not (Test-Path -PathType Any "Z:\Videos\Twitch\$($Streamer)")) { 
            New-Item -ItemType Directory -Path "Z:\Videos\Twitch\$($Streamer)" -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt"
                (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt"
                (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt").Attributes += "Hidden"
            }
        }
    
        if ($Force) {
            youtube-dl --config-location "Z:\Videos\$($Quality)_force.conf" $Urls
        }
        else {
            youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\$($Streamer)\downloaded.txt" $Urls
        }
    
        foreach ($file in Get-ChildItem $IntermediateDir) {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to 'Z:\Videos\Twitch\$($Streamer)\$($file.Name)'"
            Move-item -Path $file.Name -Destination "z:\Videos\Twitch\$($Streamer)\$($file.Name)"
        }
    }
}
finally {
    Set-Location $PreviousDirectory
}