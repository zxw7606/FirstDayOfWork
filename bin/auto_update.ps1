$INSTALLSCOOP_FILE_PATH = "$PSScriptRoot/../back/installscoop.speedup.ps1"
$INSTAL_FILE_PATH = "$PSScriptRoot/install.ps1"
$INSTAL_SPEED_UP_FILE_PATH = "$PSScriptRoot/install.speedup.ps1"

$SOFT_GROUP_FILE_PATH = "$PSScriptRoot/../dist/group.json"
$SOFT_GROUP_FILE_SPEEDUP_PATH = "$PSScriptRoot/../dist/group.speedup.json"

. "$PSScriptRoot/common.ps1"

$USE_FAST_GIT = $env:USE_FAST_GIT , "1" | Where-Object { -not [String]::IsNullOrEmpty($_) } | Select-Object -First 1 

# Define the replacement patterns
$DEFAULT_URL_MAP = [ordered]@{
    "https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1" = "https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/back/installscoop.speedup.ps1"  # use the INSTALL_PATTERN environment variable for this mapping
    "https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/dist/group.json" = "https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/dist/group.speedup.json"
}

$DEFAULT_FAST_GIT_URL_MAP = [ordered]@{
    "https://github.com" = "https://hub.fgit.ml"
    "https://raw.githubusercontent.com" = "https://raw.fastgit.org"
}

$DEFAULT_GH_GITHUB_URL_MAP = [ordered]@{
    "https://github.com" = "http://ghproxy.com/https://github.com"
    "https://raw.githubusercontent.com" = "http://ghproxy.com//https://raw.githubusercontent.com"
}

function Main {

    if ($USE_FAST_GIT -eq "1") {
        $ReplaceUrlMap = $DEFAULT_URL_MAP + $DEFAULT_FAST_GIT_URL_MAP
    }else{
        $ReplaceUrlMap = $DEFAULT_URL_MAP + $DEFAULT_GH_GITHUB_URL_MAP
    }

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

    $response = Invoke-WebRequest "https://get.scoop.sh"
    
    [System.IO.File]::WriteAllLines($INSTALLSCOOP_FILE_PATH,($response.Content | Replace-GitHubUrls -UrlMap $ReplaceUrlMap)
    , $Utf8NoBomEncoding)
    
    
    Write-Output "Successfully replaced GitHub URLs in url 'https://get.scoop.sh' and saved the result to '$INSTALLSCOOP_FILE_PATH'."
    
    [System.IO.File]::WriteAllLines($INSTAL_SPEED_UP_FILE_PATH,(Get-Content $INSTAL_FILE_PATH -Raw | Replace-GitHubUrls -UrlMap $ReplaceUrlMap)
    , $Utf8NoBomEncoding)
    
    Write-Output "Successfully replaced GitHub URLs in file '$INSTAL_FILE_PATH' and saved the result to '$INSTAL_SPEED_UP_FILE_PATH'."
    

    [System.IO.File]::WriteAllLines($SOFT_GROUP_FILE_SPEEDUP_PATH,(Get-Content $SOFT_GROUP_FILE_PATH -Raw | Replace-GitHubUrls -UrlMap $ReplaceUrlMap)
    , $Utf8NoBomEncoding)
    
    Write-Output "Successfully replaced GitHub URLs in file '$SOFT_GROUP_FILE_PATH' and saved the result to '$SOFT_GROUP_FILE_SPEEDUP_PATH'."
}

Main







