using namespace System.Collections.Generic
[CmdletBinding(DefaultParameterSetName="Download")]
param (
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Quality="480p",
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
    [string]$ConfigDir="Z:\Videos",
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Alias("Streamer","Podcast")]
    [Parameter(ParameterSetName="Download")]
    [Parameter(ParameterSetName="Batch")]
    [string]$Producer,
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
        [string[]]$Options,
        [Parameter(Mandatory=$true)]
        [string]$Output
    )
    Set-Location $Output
    youtube-dl $Options
}
try {
    $YtDlOptions = [List[string]]::new()
    [string]$Destination
    
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
        YoutubeDL $YtDlOptions.ToArray() "none"
    }
    else {
        if (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not (Test-Path -PathType Any $IntermediateDir)) {
            New-Item -ItemType Directory -Path $IntermediateDir -Force
        }

        if ([string]::IsNullOrEmpty($Producer) -and -not [string]::IsNullOrEmpty($OutDir)){
            $Destination = $OutDir
        }
        elseif (-not [string]::IsNullOrEmpty($Producer) -and -not [string]::IsNullOrEmpty($OutDir)) {
            $Destination = "$($OutDir)\$($Producer)"
        }
        elseif (-not [string]::IsNullOrEmpty($Producer) -and [string]::IsNullOrEmpty($OutDir)) {
            $Destination = "$($PreviousDirectory)\$($Producer)"
        }
        else {
            $Destination = $PreviousDirectory
        }

        if (-not (Test-Path -PathType Any $Destination)) { 
            New-Item -ItemType Directory -Path $Destination -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($Destination)\downloaded.txt"
                (Get-Item -path "$($Destination)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($Destination)\downloaded_low.txt"
                (Get-Item -path "$($Destination)\downloaded_low.txt").Attributes += "Hidden"
            }
        }

        if ((Test-Path $ConfigDir -PathType Leaf)) {
            foreach ($i in @("--config-location", $ConfigDir)) {
                $YtDlOptions.Add($i)
            }
        }
        elseif ($Force) {
            foreach ($i in @("--config-location", "$($ConfigDir)\$($Quality)_force.conf")) {
                $YtDlOptions.Add($i)
            }
        }
        else {
            foreach ($i in @("--config-location", "$($ConfigDir)\$($Quality).conf")) {
                $YtDlOptions.Add($i)
            }
        }

        if ([string]::IsNullOrEmpty($Producer)) {
            if (-not [string]::IsNullOrEmpty($BatchFile)) {
                foreach ($i in @("--download-archive", "$($Destination)\downloaded.txt", "-a", $BatchFile)) {
                    $YtDlOptions.Add($i)
                }
            }
            else {
                foreach ($i in @("--download-archive", "$($Destination)\downloaded.txt")) {
                    $YtDlOptions.Add($i)
                }
                $YtDlOptions.AddRange($Urls)
            }
        }
        else {
            if (-not [string]::IsNullOrEmpty($BatchFile)) {
                foreach ($i in @("--download-archive", "$($Destination)\downloaded.txt", "-a", $BatchFile)) {
                    $YtDlOptions.Add($i)
                }
            }
            else {
                foreach ($i in @("--download-archive", "$($Destination)\downloaded.txt")) {
                    $YtDlOptions.Add($i)
                }
                $YtDlOptions.AddRange($Urls)
            }
        }
        YoutubeDL $YtDlOptions.ToArray() $Destination
    }
        
    if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.txt","*.ytdl","*.part") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' -> '$($Destination)\$($file.Name)'"
            Move-Item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($Destination)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
}
finally {
    Set-Location $PreviousDirectory
}