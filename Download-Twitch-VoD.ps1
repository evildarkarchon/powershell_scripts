using namespace System.Collections.Generic
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
function YoutubeDL {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )
    youtube-dl $Options
}
try {
    $YtDlOptions = [List[string]]::new()
    if ($ListFormats) {
        if (-not [string]::IsNullOrEmpty($BatchFile)){
            #$YtDlOptions.AddRange(@("--list-formats", "-a", $BatchFile))
            foreach ($i in @("--list-formats", "-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
            # youtube-dl --list-formats -a $BatchFile
        }
        else {
            $YtDlOptions.Add("--list-formats")
            $YtDlOptions.AddRange($Urls)
            # youtube-dl --list-formats $Urls
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
                #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality)_force.conf", "-a", $BatchFile))
                foreach ($i in @("--config-location", "Z:\Videos\$($Quality)_force.conf", "-a", $BatchFile)) {
                    $YtDlOptions.Add($i)
                }
                # youtube-dl --config-location "Z:\Videos\$($Quality)_force.conf" -a $BatchFile
            }
            else {
                #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality)_force.conf"))
                foreach ($i in @("--config-location", "Z:\Videos\$($Quality)_force.conf")) {
                    $YtDlOptions.Add($i)
                }
                $YtDlOptions.AddRange($Urls)
                # youtube-dl --config-location "Z:\Videos\$($Quality)_force.conf" $Urls
            }
        }
        else {
            if ($Streamer.ToLower() -eq "none") {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\downloaded.txt", "-a", $BatchFile))
                    foreach ($i in @("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\downloaded.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                    # youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\downloaded.txt" -a $BatchFile
                }
                else {
                    #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\downloaded.txt"))
                    foreach ($i in @("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\downloaded.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                    # youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\downloaded.txt" $Urls
                } 
            }
            else {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\$($Streamer)\downloaded.txt", "-a", $BatchFile))
                    foreach ($i in @("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\$($Streamer)\downloaded.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                    # youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\$($Streamer)\downloaded.txt" -a $BatchFile
                }
                else {
                    #$YtDlOptions.AddRange(@("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\$($Streamer)\downloaded.txt"))
                    foreach ($i in @("--config-location", "Z:\Videos\$($Quality).conf", "--download-archive", "Z:\Videos\Twitch\$($Streamer)\downloaded.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                    # youtube-dl --config-location "Z:\Videos\$($Quality).conf" --download-archive "Z:\Videos\Twitch\$($Streamer)\downloaded.txt" $Urls
                }
            }
        }
        
        YoutubeDL($YtDlOptions.ToArray())

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