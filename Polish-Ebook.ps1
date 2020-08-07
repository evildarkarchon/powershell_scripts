[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths -ErrorAction Stop
# write-host $files.GetType().FullName
foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname) -and (Test-Path $outname -PathType Container)) {
        ebook-polish -Hup "$($file.Name)" "$($outname)\$($file.Name)"
    }
    elseif (-not [string]::IsNullOrEmpty($outname) -and -not (Test-Path $outname -PathType Any)) {
        ebook-convert "$($file.Name)" "$($outname)"
    }
    else {
        ebook-polish -Hup "$($file.Name)"
    }
}