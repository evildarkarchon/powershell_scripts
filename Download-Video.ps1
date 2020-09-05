#!/usr/bin/env pwsh
using namespace System.Collections.Generic
#using namespace System.Text
[CmdletBinding(DefaultParameterSetName="Download")]
param (
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Quality="480",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$FrameRate="30",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$IntermediateDir,
    [Alias("BaseDir")]
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$OutDir,
    [Alias("ConfigFile")]
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Config,
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Alias("Streamer","Podcast")]
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Producer,
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Series,
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$RestrictFilenames,
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$AutoNumber,    
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Download")]
    [Parameter(Mandatory=$false, Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Test")]
    [string[]]$Urls,
    [Parameter(Mandatory=$true, ParameterSetName="Batch")]
    [Parameter(Mandatory=$false, ParameterSetName="Test")]
    [string]$BatchFile
)
$PreviousDirectory = Get-Location

if ($Quality.ToLower() -eq "source") {
    $Quality = "source"
}
else {
    $Quality = $Quality -replace '[^0-9]', ''
}

function YoutubeDL {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )
    youtube-dl $Options

    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and $? -and -not $PSVersionTable.Platform -eq "Unix") {
        robocopy $IntermediateDir $Destination /mov /tbd "/r:5" /v /xf "*.txt" "*.ytdl" "*.part" "*.temp.*" "*.part-Frag*"
    }
}
try {
    $YtDlOptions = [List[string]]::new()
    [string]$Destination = ""
    
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
        YoutubeDL $YtDlOptions.ToArray()
    }
    else {
        if (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not (Test-Path -PathType Any $IntermediateDir)) {
            New-Item -ItemType Directory -Path $IntermediateDir -Force
        }
        
        if ([string]::IsNullOrEmpty($OutDir)) {
            $Destination = (Join-Path $PreviousDirectory $Producer $Series)
        }
        else {
            $Destination = (Join-Path $OutDir $Producer $Series)
        }

        if (-not (Test-Path -PathType Any $Destination)) { 
            New-Item -ItemType Directory -Path $Destination -Force
        }

        if (-not $Force) {
            if ([int]$Quality -lt 480) {
                $ArchiveFile = (Join-Path $Destination "downloaded_low.txt")
            }
            else {
                $ArchiveFile = (Join-Path $Destination "downloaded.txt")
            }
            if (-not (Test-Path -PathType Any $ArchiveFile)) {
                New-Item -ItemType File -Path $ArchiveFile
                (Get-Item -path $ArchiveFile).Attributes += "Hidden"
                }
            
            foreach ($i in @("--download-archive", $ArchiveFile)) {
                $YtDlOptions.Add($i)
            }
        }

        if (-not [string]::IsNullOrEmpty($Config) -and (Test-Path $Config -PathType Leaf)) {
            foreach ($i in @("--config-location", $Config)) {
                $YtDlOptions.Add($i)
            }
        }
        
        if ($Quality.ToLower() -eq "source") {
            $FormatString = '(bestvideo+bestaudio/best)[ext = webm]/bestvideo+bestaudio/best'
        }
        else {
            $FormatString = "(bestvideo+bestaudio/best)[height <=? $($Quality)][fps <=? $($FrameRate)][ext = webm]/(bestvideo+bestaudio/best)[height <=? $($Quality)][fps <=? $($FrameRate)]/(bestvideo+bestaudio/best)[fps <=? $($FrameRate)]/bestvideo+bestaudio/best"
        }
        
        foreach ($i in @("-f", $FormatString)) {
            $YtDlOptions.Add($i)
        }

        if ($AutoNumber) {
            if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
                $WhereTo = @("-o", (Join-Path $IntermediateDir "%(autonumber)s - %(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s"))
            }
            else {
                $WhereTo = @("-o", (Join-Path $Destination "%(autonumber)s - %(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s"))
            }
            foreach ($i in $WhereTo) {
                $YtDlOptions.Add($i)
            }
        }
        else {
            if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
                $WhereTo = @("-o", (Join-Path $IntermediateDir "%(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s"))
            }
            else {
                $Whereto = @("-o", (Join-Path $Destination "%(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s"))
            }
            foreach ($i in $WhereTo) {
                $YtDlOptions.Add($i)
            }
        }
        
        if ($RestrictFilenames) {
            $YtDlOptions.Add("--restrict-filenames")
        }

        if (-not [string]::IsNullOrEmpty($BatchFile)) {
            foreach ($i in @("-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
        }            
        else {
            $YtDlOptions.AddRange($Urls) 
        }
    }

    if (-not $ListFormats) {
        YoutubeDL $YtDlOptions.ToArray()
    }
}
finally {
    if ((get-location) -ne $PreviousDirectory) {
        Set-Location $PreviousDirectory
    }
}