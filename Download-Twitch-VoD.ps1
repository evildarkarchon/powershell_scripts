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
    [string]$OutDir="D:\Videos\Twitch",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$ConfigDir="D:\Videos",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Parameter(ParameterSetName="Download", Mandatory=$true)]
    [Parameter(ParameterSetName="Batch", Mandatory=$true)]
    [string]$Streamer,
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$Local,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Download")]
    [Parameter(Mandatory=$false, Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Test")]
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
    if ($ListFormats -eq $true) {
        $YtDlOptions.Add("--list-formats")
        if (-not [string]::IsNullOrEmpty($BatchFile)){
            foreach ($i in @("-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
        }
        else {
            $YtDlOptions.AddRange($Urls)
        }
        YoutubeDL($YtDlOptions.ToArray())
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
        
        if (-not (Test-Path -PathType Any "$($OutDir)\$($Streamer)") -and $CreateDirectories -eq $true) { 
            New-Item -ItemType Directory -Path "$($Outdir)\$($Streamer)" -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($Outdir)\$($Streamer)\downloaded.txt"
                (Get-Item -path "$($Outdir)\$($Streamer)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($Outdir)\$($Streamer)\downloaded_low.txt"
                (Get-Item -path "$($Outdir)\$($Streamer)\downloaded_low.txt").Attributes += "Hidden"
            }
        }
        if ($Force) {
            if (-not [string]::IsNullOrEmpty($BatchFile)) {
                foreach ($i in @("--config-location", "$($ConfigDir)$($Quality)_force.conf", "-a", $BatchFile)) {
                    $YtDlOptions.Add($i)
                }
            }
            else {
                foreach ($i in @("--config-location", "$($ConfigDir)$($Quality)_force.conf")) {
                    $YtDlOptions.Add($i)
                }
                $YtDlOptions.AddRange($Urls)
            }
        }
        else {
            if ($Streamer.ToLower() -eq "none") {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    foreach ($i in @("--config-location", "$($ConfigDir)$($Quality).conf", "--download-archive", "$($Outdir)\downloaded.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                }
                else {
                    foreach ($i in @("--config-location", "$($ConfigDir)$($Quality).conf", "--download-archive", "$($Outdir)\downloaded.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                } 
            }
            else {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    foreach ($i in @("--config-location", "$($ConfigDir)$($Quality).conf", "--download-archive", "$($Outdir)\$($Streamer)\downloaded.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                }
                else {
                    foreach ($i in @("--config-location", "$($ConfigDir)$($Quality).conf", "--download-archive", "$($Outdir)\$($Streamer)\downloaded.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                }
            }
        }
        
        YoutubeDL($YtDlOptions.ToArray())

        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.ytdl","*.part","*.txt") {
            if ($Streamer.ToLower() -eq "none") {
                Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' -> '$($Outdir)\$($file.Name)'"
                Move-item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($Outdir)\$($file.Name)"
            }
            else {
                Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' -> '$($Outdir)\$($Streamer)\$($file.Name)'"
                Move-item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($Outdir)\$($Streamer)\$($file.Name)"
            }
        }
    }
}
finally {
    Set-Location $PreviousDirectory
}