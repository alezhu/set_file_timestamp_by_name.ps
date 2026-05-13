param (
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $false)]
    [string]$Pattern = '(?<year>\d{4})\D*(?<month>\d{2})\D*(?<day>\d{2})\D*(?<hour>\d{2})\D*(?<minute>\d{2})\D*(?<second>\d{2})'
)

function Set-TimestampFromName {
    param (
        [System.IO.FileInfo]$File,
        [string]$RegexPattern
    )

    if ($File.Name -match $RegexPattern) {
        try {
            $year = [int]$Matches.year
            $month = [int]$Matches.month
            $day = [int]$Matches.day
            $hour = if ($Matches.hour) { [int]$Matches.hour } else { 0 }
            $minute = if ($Matches.minute) { 
                [int]$Matches.minute 
            }
            else { 
                0 
            }
            $second = if ($Matches.second) { 
                [int]$Matches.second
            }
            else { 
                0 
            }

            $date = [datetime]::new(
                $year,
                $month,
                $day,
                $hour,
                $minute,
                $second
            )

            $File.CreationTime = $date
            $File.LastWriteTime = $date
            # $File.LastAccessTime = $date

            Write-Output "File updated: $($File.FullName) -> $date"
        }
        catch {
            Write-Warning "Can't set timestamps for file '$($File.FullName)': $_"
        }
    }
    else {
        Write-Output "File skipped: $($File.Name)"
    }
}

try {
    $resolvedPath = (Resolve-Path -Path $InputPath -ErrorAction Stop).Path

    if (Test-Path -Path $resolvedPath -PathType Container) {

        Get-ChildItem -Path $resolvedPath -File -Recurse |
        ForEach-Object {
            Set-TimestampFromName -File $_ -RegexPattern $Pattern
        }

    }
    elseif (Test-Path -Path $resolvedPath -PathType Leaf) {

        $file = Get-Item -Path $resolvedPath -Force
        Set-TimestampFromName -File $file -RegexPattern $Pattern

    }
    else {
        throw "Path does not exists: $InputPath"
    }
}
catch {
    Write-Error $_
    exit 1
}