[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

if (-not [string]::IsNullOrEmpty($outname) -and $outname -eq "..") {
    $outname = (get-item (get-location)).Parent.FullName
}

$files = Get-ChildItem $paths -ErrorAction Stop
# write-host $files.GetType().FullName

foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname)) {
        if ((Test-Path $outname -PathType Container)) {
            ebook-polish -Hup "$($file.Name)" "$($outname)\$($file.Name)"
        }
        elseif (-not (Test-Path $outname -PathType Any)) {
            ebook-polish -Hup "$($file.Name)" "$($outname)"
        }
    }
    else {
        ebook-polish -Hup "$($file.Name)"
    }
}