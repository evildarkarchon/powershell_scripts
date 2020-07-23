[CmdletBinding()]
param (
    [string]$ConfigFile="z:\videos\720p.conf",
    [Alias("Out","OutputDirectory")]
    [string]$OutDir,
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Urls
)
$PreviousLocation = Get-Location
if (-not [string]::IsNullOrEmpty($OutDir)) {
    Set-Location $OutDir
}
youtube-dl --config-location "$($ConfigFile)" $Urls
if (-not [string]::IsNullOrEmpty($Outdir)) {
    Set-Location $PreviousLocation
}