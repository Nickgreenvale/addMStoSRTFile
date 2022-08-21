
param([string]$SrtFile, [int32]$Addms, [string]$minus)

# $SrtFile  - [String] path of the SRT to edit
# $AddMs    - [int32] number of milliseconds to add/minus
# $Minus    - [boolean] true if minus, false if addition

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}



# File content and new file Name
$fileSplit = $SrtFile.Split("\")
$fileName = (($fileSplit | Select-String ".srt").ToString())
$count = 1

if ($minus -eq "true") {
    $fileSuffix = "`[-$($Addms)ms" 
}else {
    $fileSuffix = "`[$($Addms)ms" 
}

$newFileName = $fileSuffix + "`]_" + $fileName

for ($i = 0; $i -lt ($fileSplit.count - 1); $i++) {
    $filePath = $filePath + $fileSplit[$i] + "\"
}

$filePath = ($filepath.Substring(0, $filepath.Length -1)).replace("``", "")

$allFiles = get-childitem -LiteralPath $filepath

# Check if file exist 
while($true) {
    $unique = $true
    foreach ($files in $allFiles) {
        if ($files.Name -eq $newFileName) {
            $newFileName = $fileSuffix + "_$($count)_`]_" + $fileName
            $count++
            $unique = $false
            break
        }
    }

    if ($unique) {
        break
    }
}

$newSrtFile = ($filepath + "\" + $newFileName).replace("``", "")




# get content of original file 
$SrtFileContent = Get-Content -LiteralPath $SrtFile
$newContent     = @()


foreach ($lines in $SrtFileContent) {
    $newLines = $lines
    if ($lines -like "* --> *") {
        $split = $lines.split(" --> ")

        if ($split.count -eq 6) {
            $originalStartTime = $split[0]
            $originalEndTime   = $split[5]

            $splitStartTime = $originalStartTime.Split(":")
            $startHour = [int]$splitStartTime[0]
            $startMin  = [int]$splitStartTime[1]
            $startSec  = [int]($splitStartTime[2].Split(","))[0]
            $startMSec = [int]($splitStartTime[2].Split(","))[1]


            $splitEndTime = $originalEndTime.Split(":")
            $endHour = [int]$splitEndTime[0]
            $endMin  = [int]$splitEndTime[1]
            $endSec  = [int]($splitEndTime[2].Split(","))[0]
            $endMSec = [int]($splitEndTime[2].Split(","))[1]

            if ($minus) {
                $startMSec = $startMSec - $addms 
                if ($startMSec -lt 0) {
                    $startSec = $startSec - [System.Math]::Ceiling(($startMSec*-1) / 1000)
                    $startMSec = $startMSec + ([System.Math]::floor(($startMSec*-1) / 1000) * 1000) + 1000

                    if ($startSec -lt 0) {
                        $startMin = $startMin - [System.Math]::Ceiling(($startSec*-1) / 60)
                        $startSec = $startSec + ([System.Math]::floor(($startSec*-1) / 60) * 60) + 60

                        if ($startMin -lt 0) {
                            $startHour = $startHour - [System.Math]::Ceiling(($startMin*-1) / 60)
                            $startMin = $startMin + ([System.Math]::floor(($startMin*-1) / 60) * 60) + 60
                        }
                    }
                }

            
                $endMSec = $endMSec - $addms 
                if ($endMSec -lt 0) {
                    $endSec = $endSec - [System.Math]::Ceiling(($endMSec*-1) / 1000)
                    $endMSec = $endMSec + ([System.Math]::floor(($endMSec*-1) / 1000) * 1000) + 1000

                    if ($endSec -lt 0) {
                        $endMin = $endMin - [System.Math]::Ceiling(($endSec*-1) / 60)
                        $endSec = $endSec + ([System.Math]::floor(($endSec*-1) / 60) * 60) + 60

                        if ($endMin -lt 0) {
                            $endHour = $endHour - [System.Math]::Ceiling(($endMin*-1) / 60)
                            $endMin = $endMin + ([System.Math]::floor(($endMin*-1) / 60) * 60) + 60
                        }
                    }
                }

            # if addition
            } else {
                $startMSec = $startMSec + $Addms
                if ($startMSec -ge 1000) {
                    $startSec   = $startsec + [System.Math]::floor($startMSec / 1000)
                    $startMSec  = ($startMSec % 1000)

                    if ($startSec -ge 60) {
                        $startMin = $startMin + [System.Math]::floor($startSec / 60)
                        $startSec = $startSec % 60

                        if ($startMin -ge 60) {
                            $startHour = $startHour + [System.Math]::Floor($startMin / 60)
                            $startMin  = $startMin % 60
                        }
                    }

                }

            
                $endMSec = $endMSec + $Addms
                if ($endMSec -ge 1000) {
                    $endSec   = $endsec + [System.Math]::floor($endMSec / 1000)
                    $endMSec  = $endMSec % 1000


                    if ($endSec -ge 60) {
                        $endMin = $endMin + [System.Math]::floor($endSec / 60)
                        $endSec = $endSec % 60

                        if ($endMin -ge 60) {
                            $endHour = $endHour + [System.Math]::Floor($endMin / 60)
                            $endMin  = $endMin % 60
                        }
                    }

                }

            }

            # Clean up
            if ($startHour -lt 10) {
                $startHour = "0" + [String]$startHour 
            } else {
                $startHour = [String]$startHour
            }

            if ($startMin -lt 10) { 
                $startMin = "0" + [String]$startMin 
            } else {
                $startMin = [String]$startMin
            }
            if ($startSec -lt 10) {
                $startSec = "0" + [String]$startSec 
            } else {
                $startSec = [String]$startSec
            }
            $startMSec  = [string]($startMSec)
            for ($i = 0; $i -lt (3 - $startMSec.Length); $i++) {
                $startMSec = "0" + $startMSec
            }



            if ($endHour -lt 10) {
                $endHour = "0" + [String]$endHour 
            } else {
                $endHour = [String]$endHour
            }

            if ($endMin -lt 10) { 
                $endMin = "0" + [String]$endMin 
            } else {
                $endMin = [String]$endMin
            }
            if ($endSec -lt 10) {
                $endSec = "0" + [String]$endSec 
            } else {
                $endSec = [String]$endSec
            }
            $endMSec  = [string]($endMSec)
            for ($i = 0; $i -lt (3 - $endMSec.Length); $i++) {
                $endMSec = "0" + $endMSec
            }

            # make line
            $newLines = $startHour + ":" + $startMin + ":" + $startSec + "," + $startMSec + `
                    " --> " + `
                        $endHour   + ":" + $endMin   + ":" + $endSec   + "," + $endMSec

        }
    }
    # new file contents
    $newContent += $newLines
}

#$newContent | Out-File ([WildcardPattern]::Escape($newSrtFile)).tostring()

# output
Set-Content -LiteralPath $newSrtFile -Value $newContent

Write-Output "`n----`noutput: $($newSrtFile)`n----`n"
