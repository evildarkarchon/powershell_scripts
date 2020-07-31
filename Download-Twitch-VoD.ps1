[CmdletBinding(DefaultParameterSetName="Download")]
param (
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Quality="480p",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$IntermediateDir="D:\Video Downloads",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Parameter(ParameterSetName="Download", Mandatory=$true)]
    [Parameter(ParameterSetName="Batch", Mandatory=$true)]
    [string]$Streamer,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Download")]
    [Parameter(Mandatory=$false, ParameterSetName="Test")]
    [string[]]$Urls,
    [Parameter(Mandatory=$true, ParameterSetName="Batch")]
    [Parameter(Mandatory=$false, ParameterSetName="Test")]
    [string]$BatchFile
)
$PreviousDirectory = Get-Location
try {
    if ($ListFormats) {
        if (-not [string]::IsNullOrEmpty($BatchFile)){
            youtube-dl --list-formats -a $BatchFile
        }
        else {
            youtube-dl --list-formats $Urls
        }
    }
    else {
        if (-not (Test-Path -PathType Any $IntermediateDir)) {
            New-Item -ItemType Directory -Path $IntermediateDir -Force
        }
        Set-Location $IntermediateDir
        [bool]$CreateDirectories = $true
        if ($Streamer.ToLower() -eq "none") {
            $CreateDirectories = $false
        }
        
        if (-not (Test-Path -PathType Container "Z:\Videos\Twitch\$($Streamer)") -and $CreateDirectories -eq $true) { 
            New-Item -ItemType Directory -Path "Z:\Videos\Twitch\$($Streamer)" -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt"
                (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt"
                (Get-Item -path "Z:\Videos\Twitch\$($Streamer)\downloaded_low.txt").Attributes += "Hidden"
            }
        }
    
        if ($Force) {
            if (-not [string]::IsNullOrEmpty($BatchFile)) {
                youtube-dl --config-location "Z:\Videos\$($Quality)_force.conf" -a $BatchFile
            }
            else {
                youtube-dl --config-location "Z:\Videos\$($Quality)_force.conf" $Urls
            }
        }
        else {
            if ($Streamer.ToLower() -eq "none") {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\downloaded.txt" -a $BatchFile
                }
                youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\downloaded.txt" $Urls
            }
            else {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\$($Streamer)\downloaded.txt" -a $BatchFile
                }
                else {
                    youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\$($Streamer)\downloaded.txt" $Urls
                }
            }
        }

        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.ytdl","*.part","*.txt") {
            if ($Streamer.ToLower() -eq "none") {
                Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to 'Z:\Videos\Twitch\$($file.Name)'"
                Move-item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "z:\Videos\Twitch\$($file.Name)"
            }
            else {
                Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to 'Z:\Videos\Twitch\$($Streamer)\$($file.Name)'"
                Move-item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "z:\Videos\Twitch\$($Streamer)\$($file.Name)"
            }
        }
    }
}
finally {
    Set-Location $PreviousDirectory
}