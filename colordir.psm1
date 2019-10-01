$Icons = @{
    ".c"    = [char]0xe61e;
    ".h"    = [char]0xe61e;
    ".cpp"  = [char]0xe61d;
    ".cs"   = [char]0xf81a;
    ".ex"   = [char]0xe62d;
    ".exs"  = [char]0xe62d;
    ".eex"  = [char]0xe62d;
    ".go"   = [char]0xe626;
    ".css"  = [char]0xe74a;
    ".d"    = [char]0xe7af;
    ".fs"   = [char]0xe7a7;
    ".erl"  = [char]0xe7b1;
    ".beam" = [char]0xe7b1;
    ".rb"   = [char]0xe791;
    ".py"   = [char]0xe606;
    ".java" = [char]0xe738;
    ".class"= [char]0xe738;
    ".lua"  = [char]0xe620;
    ".p8"   = [char]0xe620;
    ".php"  = [char]0xe608;
    ".hs"   = [char]0xe61f;
    ".js"   = [char]0xe74e;
    ".jsx"  = [char]0xe74e;
    ".vue"  = [char]0xfd42;
    ".clj"  = [char]0xe768;
    ".dart" = [char]0xe798;
    ".ts"   = [char]0xfbe4;
    ".tsx"  = [char]0xfbe4;
    ".json" = [char]0xf668;
    ".html" = [char]0xe736;
    ".url"  = [char]0xf08e;
    ".rs"   = [char]0xe7a8;
    ".ps1"  = [char]0xf120;
    ".psm1" = [char]0xf120;
    ".psd1" = [char]0xf120;
    ".sh"   = [char]0xf120;
    ".bat"  = [char]0xf120;
    ".exe"  = [char]0xf013;
    ".dll"  = [char]0xf085;
    ".msi"  = [char]0xf8d3;
    ".png"  = [char]0xf03e;
    ".gif"  = [char]0xf03e;
    ".jpg"  = [char]0xf03e;
    ".jpeg" = [char]0xf03e;
    ".bmp"  = [char]0xf03e;
    ".txt"  = [char]0xe612;
    ".md"   = [char]0xe73e;
    ".mp3"  = [char]0xf028;
    ".wav"  = [char]0xf028;
    ".ogg"  = [char]0xf028;
    ".mid"  = [char]0xe601;
    ".sf2"  = [char]0xfb7b;
    ".zip"  = [char]0xf187;
    ".rar"  = [char]0xf187;
    ".7z"   = [char]0xf187;
    ".lnk"  = [char]0xf0c1;
    ".iso"  = [char]0xe271;
    ".mp4"  = [char]0xf008;
    ".flv"  = [char]0xf008;
    ".wmv"  = [char]0xf008;
    ".webm" = [char]0xf008;
    ".mkv"  = [char]0xf008;
    ".rdb"  = [char]0xe76d;
    ".blend"= [char]0xf5aa;
    ".lock" = [char]0xf023;
    ".pgp"  = [char]0xf084;
    ".pem"  = [char]0xf084;
    ".ppk"  = [char]0xf084;
    ".key"  = [char]0xf084;
    ".pub"  = [char]0xf084;
    ""      = [char]0xf15b;
    ".torrent"  = [char]0xf019;
    ".gitignore"= [char]0xe702;
    ".gitconfig"= [char]0xe702;
    ".mcmeta"   = [char]0xf872;
    ".nomedia"  = [char]0xf070;
}

$GitColors = @{
    "M  " = "Yellow";
    "A  " = "Cyan";
    "D  " = "Red";
    "R  " = "White";
    "C  " = "Blue";
    "T  " = "Magenta";
    "U  " = "DarkRed";
    "?  " = "DarkRed";
    "v  " = "Green";
    "$([char]0xf00c)  "  = "Green";
}

$ExecutableTypes = ".exe", ".msi", ".bat", ".ps1"

function Get-ColoredItem {

    [CmdletBinding()]

    Param(
        [String]$Dir = ".\",
        [ValidateSet("NameDescending", "NameAscending", "Newest", "Oldest", "SizeDescending", "SizeAscending")]
        [String]$SortBy = "NameAscending",
        [Switch]$Git = $False,
        [Switch]$FolderSize = $False,
        [Switch]$NoIcons = $False
    )

    $WillRun = $True

    try {
        $Folders = Get-ChildItem $Dir -Directory -Force -ErrorAction Stop
        $Items = Get-ChildItem $Dir -File -Force -ErrorAction Stop    
    } catch {
        $WillRun = $False
    }

    if (!$NoIcons) {
        $ADI = [char]0xf023
    } else {
        $ADI = "X"
    }

    if ($WillRun) {
        if ($Git) {
            $Found = $False
            try {
                if ((Invoke-Command {git rev-parse --is-inside-work-tree}) -eq "true") {
                    $Found = $True
                }
                if (!$Found) {
                    Write-Host "Directory is not a Git repository, ignoring the Git argument" -ForegroundColor DarkRed
                    $Git = $False
                } else {
                    if (!$NoIcons) {
                        $commit = [char]0xe729
                    } else {
                        $commit = "Git:"
                    }
                    Write-Host "$($commit) $(Invoke-Command {git show-branch --current})" -ForegroundColor Cyan
                    $GitDiff = (Invoke-Command {git status --short}).Split("`n")
                }
            } catch {
                Write-Host "Git not detected. Are you sure the executable is in your path?" -ForegroundColor Red
                $Git = $False
            }
        }

        Switch ($SortBy) {
            "NameDescending" {
                $Folders = $Folders | Sort-Object -Property Name -Descending
                $Items = $Items | Sort-Object -Property Name -Descending
            }
            "NameAscending" {
                $Folders = $Folders | Sort-Object -Property Name
                $Items = $Items | Sort-Object -Property Name
            }
            "SizeDescending" {
                if ($FolderSize) {
                    $Folders = $Folders | Sort-Object {(Get-ChildItem $_ -Recurse | Measure-Object -Property Length -Sum).sum} -Descending
                }
                $Items = $Items | Sort-Object -Property Length -Descending
            }
            "SizeAscending" {
                if ($FolderSize) {
                    $Folders = $Folders | Sort-Object {(Get-ChildItem $_ -Recurse | Measure-Object -Property Length -Sum).sum}
                }
                $Items = $Items | Sort-Object -Property Length
            }
            "Newest" {
                $Folders = $Folders | Sort-Object -Property LastWriteTime -Descending
                $Items = $Items | Sort-Object -Property LastWriteTime -Descending
            }
            "Oldest" {
                $Folders = $Folders | Sort-Object -Property LastWriteTime
                $Items = $Items | Sort-Object -Property LastWriteTime
            }
        }

        if ($Git) {
            if ($NoIcons) {
                $GitLabel = "S  "
            } else {
                $GitLabel = "$([char]0xf1d3)  "
            }
        }

        Write-Host "Mode$([char]0x0009)Size$([char]0x0009)Last Written$([char]0x0009)     $($GitLabel)Name"

        foreach ($d in $Folders) {
            $Icon = ""
            if (!$NoIcons) {
                Switch ($d.name) {
                    ".git" {$Icon = [char]0xe5fb}
                    "config" {$Icon = [char]0xe5fc}
                    "node_modules" {$Icon = [char]0xe5fa}
                    "src" {$Icon = [char]0xf121}
                    ".vs" {$Icon = [char]0xfb0f}
                    ".vscode" {$Icon = [char]0xfb0f}
                    "__pycache__" {$Icon = [char]0xe606}
                    Default {$Icon = [char]0xe5ff}
                }
            }
            if ($FolderSize) {
                $r = Get-Size "$d" -Recursive
                $size = $r[0]
                $AccessDenied = $r[1]
            } else {
                $size = " "
                $AccessDenied = $False
            }
            $Name = $d.Name
            if (Test-ReparsePoint $d) {
                $Color = "Magenta"
                if ($d.Target -ne $_) {
                    $Name = "$Name -> $($d.Target)"
                }
            } else {
                $Color = "Blue"
            }
            $Screenspace = $Host.UI.RawUI.WindowSize.Width - 16 - "$($d.Mode)$([char]0x0009)$($size)$([char]0x0009)$($d.LastWriteTime)  $($Icon) ".Length
            [Int]$HSS = $Screenspace / 2
            if ($Name.Length -gt $Screenspace) {
                $Dif = $Name.Length - $Screenspace
                $Name1 = $Name.subString(0, $HSS - 3)
                $Name2 = $Name.subString($HSS + 3 + $Dif, $Name.Length - ($HSS + 3 + $Dif))
                $Name = "$Name1...$Name2"
            }
            if ([convert]::ToString($d.Attributes.Value__, 2) -match "\d?\d?\d?\d?1\d$") {
                $Color = "Dark$Color"
            }

            if ($Git) {
                $GitIcon = "   "
            }

            Write-Host "$($d.Mode)$([char]0x0009)$($size)$([char]0x0009)$($d.LastWriteTime)  $($GitIcon)$($Icon) $($Name)" -ForegroundColor $Color -NoNewline
            if ($AccessDenied) {Write-Host " $ADI" -ForegroundColor Red -NoNewline}
            Write-Host ""
        }

        foreach ($i in $Items) {
            if (!$NoIcons) {
                $Icon = $Icons[$i.extension.ToLower()]
                if ($Icon -eq $_) {$Icon = $Icons[""]}
                Switch ($True) {
                    ($i.Name -like "*LICENSE*") {$Icon = [char]0xf1f9}
                    ($i.Name -like "*id_rsa*") {$Icon = [char]0xf084}
                }    
            }
            $r = Get-Size "$i"
            $size = $r[0]
            $AccessDenied = $r[1]
            $Name = $i.Name
            $Screenspace = $Host.UI.RawUI.WindowSize.Width - 16 - "$($i.Mode)$([char]0x0009)$($size)$([char]0x0009)$($i.LastWriteTime)  $($Icon) ".Length
            [Int]$HSS = $Screenspace / 2
            if ($Name.Length -gt $Screenspace) {
                $Dif = $Name.Length - $Screenspace
                $Name1 = $Name.subString(0, $HSS - 3)
                $Name2 = $Name.subString($HSS + 3 + $Dif, $Name.Length - ($HSS + 3 + $Dif))
                $Name = "$Name1...$Name2"
            }
            if ($ExecutableTypes -contains $i.Extension) {
                $Color = "Yellow"
            } elseif ($i.Extension -eq ".lnk") {
                $Color = "Magenta"
            } else {
                $Color = "Green"
            }
            if ([convert]::ToString($i.Attributes.Value__, 2) -match "\d?\d?\d?\d?1\d$") {
                $Color = "Dark$Color"
            }

            if ($Git) {
                $GitIcon = $_
                foreach ($s in $GitDiff) {
                    if ($s -like "*$($i.Name)*") {
                        $_ = $s -match "(?:[MADCRTUXB]|\?\?)\s*\S*"
                        $GitIcon = "$($Matches[0][0])  "
                    }
                }
                if ($GitIcon -eq $_) {
                    if ($NoIcons) {
                        $GitIcon = "v  "
                    } else {
                        $GitIcon = "$([char]0xf00c)  "
                    }
                }
            } else {
                $GitIcon = ""
            }

            Write-Host "$($i.Mode)$([char]0x0009)$($size)$([char]0x0009)$($i.LastWriteTime)  " -ForegroundColor $Color -NoNewline
            if ($Git) {Write-Host "$($GitIcon)" -ForegroundColor $GitColors[$GitIcon] -NoNewline}
            Write-Host "$($Icon) $($Name)" -ForegroundColor $Color -NoNewline
            if ($AccessDenied) {Write-Host " $ADI" -ForegroundColor Red -NoNewline}
            Write-Host ""
        }
    } else {
        Write-Host "$ADI Access to the requested directory denied." -ForegroundColor Red
    }
}

function Get-ColoredTree {

}

function Get-Size {

    Param(
        [Parameter(Mandatory=$True)]
        [String]$Item,
        [Switch]$Recursive = $False
    )

    $acc = $False

    try {
        if ($Recursive) {
            $foldersize = Get-ChildItem "$Item" -Force -Recurse -ErrorAction Stop | Measure-Object -Property Length -Sum -ErrorAction Stop
        } else {
            $foldersize = Get-Item "$Item" -Force -ErrorAction Stop | Measure-Object -Property Length -Sum -ErrorAction Stop
        }
    
        Switch ($True) {
            ($foldersize.sum -gt 1KB) {$size = "$([math]::Round(($foldersize.sum / 1KB), 2))KB"}
            ($foldersize.sum -gt 100KB) {$size = "$([math]::Round(($foldersize.sum / 1KB)))KB"}
            ($foldersize.sum -gt 1MB) {$size = "$([math]::Round(($foldersize.sum / 1MB), 2))MB"}
            ($foldersize.sum -gt 100MB) {$size = "$([math]::Round(($foldersize.sum / 1MB)))MB"}
            ($foldersize.sum -gt 1GB) {$size = "$([math]::Round(($foldersize.sum / 1GB), 2))GB"}
            ($foldersize.sum -gt 100GB) {$size = "$([math]::Round(($foldersize.sum / 1GB)))GB"}
            ($foldersize.sum -gt 1TB) {$size = "$([math]::Round(($foldersize.sum / 1TB), 2))TB"}
            Default {$size = $foldersize.sum}
        }
    } catch [System.Management.Automation.PSArgumentException] {
        $size = 0
    } catch {
        $acc = $True
        $size = "?"
    }
    if ($size -eq $nil) {$size = 0}
    return $size, $acc
}

function Test-ReparsePoint([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
  }
