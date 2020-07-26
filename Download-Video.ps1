[CmdletBinding()]
param (
    [string]$ConfigFile="z:\videos\720p.conf",
    [switch]$Force,
    [Alias("o","Out","OutputDirectory")]
    [string]$OutDir,
    [string]$IntermediateDir,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousLocation = Get-Location
write-host $OutDir
try {
    if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
        if (-not (Test-Path -PathType Any "$($IntermediateDir)")) {
            New-Item -ItemType Directory -Path "$($IntermediateDir)" -Force
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
            youtube-dl --config-location "$($ConfigFile)" --download-archive "$($IntermediateDir)\downloaded_ps.txt" $Urls
        }
        
    }
    elseif (-not [string]::IsNullOrEmpty($OutDir)){
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
    else {
        youtube-dl --config-location "$($ConfigFile)" $Urls
    }
    
    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and [string]::IsNullOrEmpty($OutDir)) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "downloaded_ps.txt") {
            Write-Host "'Moving $($file.Name)' to '$($PreviousLocation)\$($file.Name)"
            Move-Item "$($file.Name)" "$($PreviousLocation)\$($file.Name)"
        }
    }
    elseif (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not [string]::IsNullOrEmpty($OutDir)) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "downloaded_ps.txt") {
            Write-Host "'Moving $($file.Name)' to '$($OutDir)\$($file.Name)"
            Move-Item "$($file.Name)" "$($OutDir)\$($file.Name)"
        }
    }
}
finally {
    Set-Location $PreviousLocation
}