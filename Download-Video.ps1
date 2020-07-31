using namespace System.Collections.Generic
[CmdletBinding(DefaultParameterSetName="Download")]
param (
    [Parameter(ParameterSetName="Batch")]
    [Parameter(ParameterSetName="Download")]
    [string]$ConfigFile="z:\videos\720p.conf",
    [Parameter(ParameterSetName="Batch")]
    [Parameter(ParameterSetName="Download")]
    [switch]$Force,
    [Parameter(ParameterSetName="Test")]
    [switch]$ListFormats,
    [Parameter(ParameterSetName="Batch")]
    [Parameter(ParameterSetName="Download")]
    [string]$OutDir,
    [Parameter(ParameterSetName="Batch")]
    [Parameter(ParameterSetName="Download")]
    [string]$IntermediateDir,
    [Parameter(ParameterSetName="Batch")]
    [Parameter(ParameterSetName="Test")]
    [string]$BatchFile,
    [Parameter(Position=0, ValueFromRemainingArguments=$true, ParameterSetName="Download")]
    [Parameter(ParameterSetName="Test")]
    [string[]]$Urls
)
$PreviousLocation = Get-Location
function YoutubeDL {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )
    youtube-dl $Options
}
try {
    $YtDlOptions = [List[string]]::new()
    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not $ListFormats) {
        if (-not (Test-Path -PathType Any $IntermediateDir)) {
            New-Item -ItemType Directory -Path $IntermediateDir -Force
        }
        if (-not (Test-Path -PathType Any $OutDir) -and -not [string]::IsNullOrEmpty($OutDir)) {
            New-Item -ItemType Directory -Path $OutDir -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($OutDir)\downloaded.txt"
                (Get-Item -LiteralPath "$($OutDir)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($OutDir)\downloaded_low.txt"
                (Get-Item -LiteralPath "$($OutDir)\downloaded_low.txt").Attributes += "Hidden"
            }
        } 
        Set-Location $IntermediateDir
        
        if (-not (Test-Path -PathType Any "$($IntermediateDir)\downloaded_ps.txt") -and -not $Force){
            New-Item -ItemType File -Path "$($IntermediateDir)\downloaded_ps.txt"
            (Get-Item -LiteralPath "$($IntermediateDir)\downloaded_ps.txt").Attributes += "Hidden"
        }
        
        if ($Force) {
            if (-not [string]::IsNullOrEmpty($BatchFile)) {
                # $YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "-a", [string]$BatchFile))
                foreach ($i in @("--config-location", $ConfigFile, "-a", $BatchFile)) {
                    $YtDlOptions.Add($i)
                }
                # youtube-dl --config-location $ConfigFile -a $BatchFile
            }
            else {
                #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile))
                foreach ($i in @("--config-location", $ConfigFile)) {
                    $YtDlOptions.Add($i)
                }
                $YtDlOptions.AddRange($Urls)
                # youtube-dl --config-location $ConfigFile $Urls
            }
        }
        else {
            if (-not [string]::IsNullOrEmpty($OutDir)) {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "--download-archive", "$($OutDir)\downloaded.txt"), "-a", [string]$BatchFile))
                    foreach ($i in @("--config-location", $ConfigFile, "--download-archive", "$($OutDir)\downloaded.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                    # youtube-dl --config-location $ConfigFile --download-archive "$($OutDir)\downloaded.txt" -a $BatchFile
                }
                else {
                    #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "--download-archive", "$($OutDir)\downloaded.txt"))
                    foreach ($i in @("--config-location", $ConfigFile, "--download-archive", "$($OutDir)\downloaded.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                    # youtube-dl --config-location $ConfigFile --download-archive "$($OutDir)\downloaded.txt" $Urls
                }
            }
            else {
                if (-not [string]::IsNullOrEmpty($BatchFile)) {
                    #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "--download-archive", "$($IntermediateDir)\downloaded_ps.txt"), "-a", [string]$BatchFile)
                    foreach ($i in @("--config-location", $ConfigFile, "--download-archive", "$($IntermediateDir)\downloaded_ps.txt", "-a", $BatchFile)) {
                        $YtDlOptions.Add($i)
                    }
                    # youtube-dl --config-location $ConfigFile --download-archive "$($IntermediateDir)\downloaded_ps.txt" -a $BatchFile
                }
                else {
                    #$YtDlOptions.AddRange(@("--config-location", $ConfigFile, "--download-archive", "$($IntermediateDir)\downloaded_ps.txt"))
                    foreach ($i in @("--config-location", $ConfigFile, "--download-archive", "$($IntermediateDir)\downloaded_ps.txt")) {
                        $YtDlOptions.Add($i)
                    }
                    $YtDlOptions.AddRange($Urls)
                    # youtube-dl --config-location $ConfigFile --download-archive "$($IntermediateDir)\downloaded_ps.txt" $Urls
                }
            }
        }
    }
    elseif (-not [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats){
        if (-not (Test-Path -PathType Any $OutDir)) {
            New-Item -ItemType Directory -Path $OutDir -Force
            if (-not $Force) {
                New-Item -ItemType File -Path "$($OutDir)\downloaded.txt"
                (Get-Item -path "$($OutDir)\downloaded.txt").Attributes += "Hidden"
                New-Item -ItemType File -Path "$($OutDir)\downloaded_low.txt"
                (Get-Item -path "$($OutDir)\downloaded_low.txt").Attributes += "Hidden"
            } 
        }
        Set-Location $OutDir
        if (-not [string]::IsNullOrEmpty($BatchFile)) {
            # $YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "-a", [string]$BatchFile))
            foreach ($i in @("--config-location", $ConfigFile, "-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
            # youtube-dl --config-location $ConfigFile -a $BatchFile
        }
        else {
            #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile))
            foreach ($i in @("--config-location", $ConfigFile)) {
                $YtDlOptions.Add($i)
            }
            $YtDlOptions.AddRange($Urls)
            # youtube-dl --config-location $ConfigFile $Urls
        }
    }
    elseif ($ListFormats) {
        if (-not [string]::IsNullOrEmpty($BatchFile)) {
            #$YtDlOptions.AddRange(@("--list-formats", "-a", [string]$BatchFile))
            foreach ($i in @("--list-formats", "-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
            # youtube-dl --list-formats -a $BatchFile
        }
        else {
            $YtDlOptions.Add("--list-formats")
            $YtDlOptions.AddRange($Urls)
            # youtube-dl --list-formats $Urls
        }
    }
    else {
        if (-not [string]::IsNullOrEmpty($BatchFile)) {
            #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile, "-a", [string]$BatchFile))
            foreach ($i in @("--config-location", $ConfigFile, "-a", $BatchFile)) {
                $YtDlOptions.Add($i)
            }
            # youtube-dl --config-location $ConfigFile -a $BatchFile
        }
        else {
            #$YtDlOptions.AddRange(@("--config-location", [string]$ConfigFile))
            foreach ($i in @("--config-location", $ConfigFile)) {
                $YtDlOptions.Add($i)
            }
            $YtDlOptions.AddRange($Urls)
            # youtube-dl --config-location $ConfigFile $Urls
        }
    }
    
    YoutubeDL($YtDlOptions.ToArray())

    if (-not [string]::IsNullOrEmpty($IntermediateDir) -and [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.txt","*.ytdl","*.part") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to '$($PreviousLocation)\$($file.Name)'"
            Move-Item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($PreviousLocation)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
    elseif (-not [string]::IsNullOrEmpty($IntermediateDir) -and -not [string]::IsNullOrEmpty($OutDir) -and -not $ListFormats) {
        foreach ($file in Get-ChildItem $IntermediateDir -Exclude "*.txt","*.ytdl","*.part") {
            Write-Host "[powershell] Moving '$($IntermediateDir)\$($file.Name)' to '$($OutDir)\$($file.Name)"
            Move-Item -LiteralPath "$($IntermediateDir)\$($file.Name)" -Destination "$($OutDir)\$($file.Name)"
            if (Test-Path $file -PathType Any) {
                Remove-Item -Force $file
            }
        }
    }
}
finally {
    Set-Location $PreviousLocation
}