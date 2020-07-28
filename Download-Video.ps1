[CmdletBinding()]
param (
    [Parameter(ParameterSetName="Download")]
    [string]$ConfigFile="z:\videos\720p.conf",
    [Parameter(ParameterSetName="Download")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Alias("o","Out","OutputDirectory")]
    [Parameter(ParameterSetName="Download")]
    [string]$OutDir,
    [Parameter(ParameterSetName="Download")]
    [string]$IntermediateDir,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousLocation = Get-Location
try {
    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not $ListFormats) {
        if (-not (Test-Path -PathType Any "$($IntermediateDir)")) {
            New-Item -ItemType Directory -Path "$($IntermediateDir)" -Force
        }
        if (-not (Test-Path -PathType Any "$($OutDir)") -and -not [string]::IsNullOrEmpty($OutDir)) {
            New-Item -ItemType Directory -Path "$($OutDir)" -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($OutDir)\downloaded.txt"
                (Get-Item -path "$($OutDir)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($OutDir)\downloaded_low.txt"
                (Get-Item -path "$($OutDir)\downloaded_low.txt").Attributes += "Hidden"
            }
        } 
        Set-Location $IntermediateDir
        
        if (-not (Test-Path -PathType Any "$($IntermediateDir)\downloaded_ps.txt") -and -not $Force){
            New-Item -ItemType File -Path "$($IntermediateDir)\downloaded_ps.txt"
            (Get-Item -path "$($IntermediateDir)\downloaded_ps.txt").Attributes += "Hidden"
        }
        
        if ($Force) {
            youtube-dl --config-location "$($ConfigFile)" $Urls
        }
        else {
            if (-not [string]::IsNullOrEmpty($OutDir)) {
                youtube-dl --config-location "$($ConfigFile)" --download-archive "$($OutDir)\downloaded.txt" $Urls
            }
            else {
                youtube-dl --config-location "$($ConfigFile)" --download-archive "$($IntermediateDir)\downloaded_ps.txt" $Urls
            }
        }
    }
    elseif (-not [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats){
        if (-not (Test-Path -PathType Any "$($OutDir)")) {
            New-Item -ItemType Directory -Path "$($OutDir)" -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($OutDir)\downloaded.txt"
                (Get-Item -path "$($OutDir)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($OutDir)\downloaded_low.txt"
                (Get-Item -path "$($OutDir)\downloaded_low.txt").Attributes += "Hidden"
            } 
        }
        Set-Location $OutDir
        youtube-dl --config-location "$($ConfigFile)" $Urls
    }
    elseif ($ListFormats) {
        youtube-dl --list-formats $Urls
    }
    else {
        youtube-dl --config-location "$($ConfigFile)" $Urls
    }
    
    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "downloaded_ps.txt" -Exclude "*.ytdl","*.part") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to '$($PreviousLocation)\$($file.Name)'"
            Move-Item "$($IntermediateDir)\$($file.Name)" "$($PreviousLocation)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
    elseif (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "downloaded_ps.txt" -Exclude "*.ytdl","*.part") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to '$($OutDir)\$($file.Name)"
            Move-Item "$($IntermediateDir)\$($file.Name)" "$($OutDir)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
}
finally {
    Set-Location $PreviousLocation
}