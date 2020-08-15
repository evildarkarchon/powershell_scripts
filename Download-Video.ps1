using namespace System.Collections.Generic
using namespace System.Text
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
$Quality = $Quality.Replace("p", "")
function YoutubeDL {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )
    youtube-dl $Options
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
        $DestinationSB = [StringBuilder]::new()
        if (-not [string]::IsNullOrEmpty($OutDir)){
            [void]$DestinationSB.Append($OutDir)
            if (-not [string]::IsNullOrEmpty($Producer)) {
                [void]$DestinationSB.Append("\")
                [void]$DestinationSB.Append($Producer)
            }
        }
        else {
            [void]$DestinationSB.Append($PreviousDirectory)
            if (-not [string]::IsNullOrEmpty($Producer) -and [string]::IsNullOrEmpty($OutDir)) {
                [void]$DestinationSB.Append("\")
                [void]$DestinationSB.Append($Producer)
            }
        }

        if (-not [string]::IsNullOrEmpty($Series)) {
            [void]$DestinationSB.Append("\")
            [void]$DestinationSB.Append($Series)
        }

        $Destination = $DestinationSB.ToString()

        if (-not (Test-Path -PathType Any $Destination)) { 
            New-Item -ItemType Directory -Path $Destination -Force
        }
        if (-not $Force) {
            if (-not (Test-Path -PathType Any "$($Destination)\downloaded.txt")) {
                New-Item -ItemType File -Path "$($Destination)\downloaded.txt"
                (Get-Item -path "$($Destination)\downloaded.txt").Attributes += "Hidden"
                }
            if (-not (Test-Path -PathType Any "$($Destination)\downloaded_low.txt")) {
                New-Item -ItemType File -Path "$($Destination)\downloaded_low.txt"
                (Get-Item -path "$($Destination)\downloaded_low.txt").Attributes += "Hidden"
            }
        }

        if (-not [string]::IsNullOrEmpty($Config) -and (Test-Path $Config -PathType Leaf)) {
            foreach ($i in @("--config-location", $Config)) {
                $YtDlOptions.Add($i)
            }
        }
        
        $FormatString = "(bestvideo+bestaudio/best)[height <=? $($Quality)][fps <=? $($FrameRate)][ext = webm]/(bestvideo+bestaudio/best)[height <=? $($Quality)][fps <=? $($FrameRate)]/(bestvideo+bestaudio/best)[fps <=? $($FrameRate)]/bestvideo+bestaudio/best"
        foreach ($i in @("-f", $FormatString)) {
            $YtDlOptions.Add($i)
        }
        #elseif ($Force) {
        #    foreach ($i in @("--config-location", "$($ConfigDir)\$($Quality)_force.conf")) {
        #        $YtDlOptions.Add($i)
        #    }
        #}
        #else {
        #    foreach ($i in @("--config-location", "$($ConfigDir)\$($Quality).conf")) {
        #        $YtDlOptions.Add($i)
        #    }
        #}

        if ($AutoNumber) {
            [string[]]$WhereTo
            if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
                $WhereTo = @("-o", "$($IntermediateDir)\%autonumber - %(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s")
            }
            else {
                $WhereTo = @("-o", "$($Destination)\%autonumber - %(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s")
            }
            foreach ($i in $WhereTo) {
                $YtDlOptions.Add($i)
            }
        }
        else {
            [string[]]$WhereTo
            if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
                $WhereTo = @("-o", "$($IntermediateDir)\%(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s")
            }
            else {
                $WhereTo = @("-o", "$($Destination)\%(title)s-%(id)s_%(height)sp@%(fps)s.%(ext)s")
            }
            foreach ($i in $WhereTo) {
                $YtDlOptions.Add($i)
            }
        }
        if (-not $Force) {
            foreach ($i in @("--download-archive", "$($Destination)\downloaded.txt")) {
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
        # write-host $YtDlOptions.ToArray()
        YoutubeDL $YtDlOptions.ToArray()
    }
        
    if (-not [string]::IsNullOrEmpty($IntermediateDir)) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.txt","*.ytdl","*.part","*.temp.*") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' -> '$($Destination)\$($file.Name)'"
            Move-Item -Force -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($Destination)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
}
finally {
    Set-Location $PreviousDirectory
}