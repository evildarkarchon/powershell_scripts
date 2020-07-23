[CmdletBinding()]
param (
    [string]$ConfigFile="z:\videos\720p.conf",
    [Alias("Out","OutputDirectory")]
    [string]$OutDir,
    [string]$IntermediateDir,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousLocation = Get-Location

if (-not [string]::IsNullOrEmpty($OutDir) -and -not (Test-Path -PathType Any "$($Outdir)")) { 
    New-Item -ItemType Directory -Path "$($OutDir)"
    New-Item -ItemType File -Path "$($OutDir)\downloaded.txt"
    (Get-Item -path "$($OutDir)\downloaded.txt").Attributes += "Hidden"
    New-Item -ItemType File -Path "$($OutDir)\downloaded_low.txt"
    (Get-Item -path "$($OutDir)\downloaded_low.txt").Attributes += "Hidden"
}

if (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not (Test-Path -PathType Any "$($IntermediateDir)")) { 
    New-Item -ItemType Directory -Path "$($IntermediateDir)"
}

#if (-not [string]::IsNullOrEmpty($OutDir)) {
#    Set-Location $OutDir
#}
#elseif (-not [string]::IsNullOrEmpty($IntermediateDir)) {
#    Set-Location $IntermediateDir
#}
if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
    Set-Location $IntermediateDir
    
    if (-not (Test-Path -PathType Any "$($IntermediateDir)\downloaded_ps.txt")){
        New-Item -ItemType File -Path "$($IntermediateDir)\downloaded_ps.txt"
        (Get-Item -path "$($IntermediateDir)\downloaded_ps.txt").Attributes += "Hidden"
    }
    
    youtube-dl --config-location "$($ConfigFile)" --download-archive "$($IntermediateDir)\downloaded_ps.txt" $Urls
}
else {
    if (-not [string]::IsNullOrEmpty($OutDir)) {
        Set-Location $OutDir
    }
    
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

Set-Location $PreviousLocation