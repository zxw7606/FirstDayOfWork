<#
.SYNOPSIS
    Scoop installer.
.DESCRIPTION
    The installer of Scoop. For details please check the website and wiki.
.PARAMETER ScoopDir
    Specifies Scoop root path.
    If not specified, Scoop will be installed to '$env:USERPROFILE\scoop'.
.PARAMETER ScoopGlobalDir
    Specifies directory to store global apps.
    If not specified, global apps will be installed to '$env:ProgramData\scoop'.
.PARAMETER ScoopCacheDir
    Specifies cache directory.
    If not specified, caches will be downloaded to '$ScoopDir\cache'.
.PARAMETER NoProxy
    Bypass system proxy during the installation.
.PARAMETER Proxy
    Specifies proxy to use during the installation.
.PARAMETER ProxyCredential
    Specifies credential for the given proxy.
.PARAMETER ProxyUseDefaultCredentials
    Use the credentials of the current user for the proxy server that is specified by the -Proxy parameter.
.PARAMETER RunAsAdmin
    Force to run the installer as administrator.
.PARAMETER SoftUrl
    Soft List
.LINK
    https://scoop.sh
.LINK
    https://github.com/ScoopInstaller/Scoop/wiki
#>
param(
    [Parameter(Position = 0)][String] $SoftUrl = "https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/dist/group.json",
    [String] $ScoopDir,
    [String] $ScoopGlobalDir,
    [String] $ScoopCacheDir,
    [Switch] $NoProxy,
    [Uri] $Proxy,
    [System.Management.Automation.PSCredential] $ProxyCredential,
    [Switch] $ProxyUseDefaultCredentials,
    [Switch] $RunAsAdmin

)

<# i18n #>

function Get-i18n-Helper {
    param([Parameter(Mandatory = $true, Position = 0)][string]$Url)    
    # 将 JSON 数据解析为对象
    $data = Get-Json-From-Url $Url
    $map = @{}
    Flatten $map $data ''
    $properties = @{
        map = $map
    }

    $obj = New-Object -TypeName PSObject -Property $properties
    $obj | Add-Member -MemberType ScriptMethod -Name "parse" -Value ({
            param(
                [string]$key,
                [Parameter(ValueFromRemainingArguments = $true)]
                $Args
            )
            $LocalizedString = $this.map[$key], $key | Where-Object { ![String]::IsNullOrWhiteSpace($_) } | Select-Object -First 1

            if ($Args) {
                return $LocalizedString -f $Args
            }
            else {
                return $LocalizedString
            }
        })
    return $obj;
    
}

function Flatten($map, $obj, $prefix) {
    foreach ($prop in $obj.psobject.properties) {
        $key = if ($prefix) { "$prefix.$($prop.Name)" } else { $prop.Name }
        if ($prop.Value.GetType().Name -eq 'PSCustomObject') {
            Flatten $map $prop.Value $key
        }
        else {
            $map[$key] = $prop.Value
        }
    }
}

function Test-CommandAvailable {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $Command
    )
    return [Boolean](Get-Command $Command -ErrorAction Ignore)
}


function Log-ScoopVersion {
    if (!(Test-CommandAvailable "scoop")) {
        Write-Output "SCOOP VERSION: Not found"
    }
    else {
        Write-Output "SCOOP VERSION: $((scoop --version))"
    }
}

# install Scoop 
function Install-Scoop {
   
  
    if (!(Test-CommandAvailable "scoop")) {
        Invoke-WebRequest -useb "$SCOOP_INSALL_SH_URL" | Invoke-Expression
        # Invoke-RestMethod "$SCOOP_INSALL_SH_URL" -outfile '.\temp_install.ps1'

        # $arguments = ""

        # if ($ScoopDir -ne "") {
        #     $arguments = $arguments + "-ScoopDir $ScoopDir "
        # }
        
        # if ($ScoopGlobalDir -ne "") {
        #     $arguments = $arguments + "-ScoopGlobalDir $ScoopGlobalDir "
        # }
        
        # if ($ScoopCacheDir -ne "") {
        #     $arguments = $arguments + "-ScoopCacheDir $ScoopCacheDir "
        # }
        
        # if ($NoProxy) {
        #     $arguments = $arguments + "-NoProxy $NoProxy "
        # }
        
        # if ($null -ne $Proxy) {
        #     $arguments = $arguments + "-Proxy $Proxy "
        # }
        
        # if ($null -ne $ProxyCredential) {
        #     $arguments = $arguments + "-ProxyCredential $ProxyCredential "
        # }

        # if($ProxyUseDefaultCredentials){
        #     $arguments = $arguments + "-ProxyUseDefaultCredentials"
        # }
        
        # if ($RunAsAdmin) {
        #     $arguments = $arguments + "-RunAsAdmin "
        # }
        
        # ".\temp_install.ps1 $arguments"

        if ((Test-CommandAvailable "scoop")) {
            Write-Output "SCOOP INSTALL SUCCESS";
        }
        else {
            Write-Output "SCOOP INSTALL FAILED";
        }
    }
    else {
        Write-Output "Scoop has already installed, skip";
    }

    # $buckets = @(
    #     @{
    #         "bucket-name" = "main"
    #         "bucket-url"  = "https://github.com/ScoopInstaller/Main"
    #     },
    #     @{
    #         "bucket-name" = "extras"
    #         "bucket-url"  = "https://github.com/ScoopInstaller/Extras"
    #     },
    #     @{
    #         "bucket-name" = "java"
    #         "bucket-url"  = "https://github.com/ScoopInstaller/Java"
    #     }
    # )

    # foreach ($bucket in $buckets) {
    #     Write-Host "Adding bucket $($bucket.'bucket-name')..."
    #     scoop bucket add $($bucket.'bucket-name') $($bucket.'bucket-url')
    # }

    # Write-Host "All buckets have been added successfully."


}

function Get-Json-From-Url {
    param([Parameter(Mandatory = $true)]$Url)
    $response = Invoke-RestMethod $Url
    # $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($response.Content)
    # $content = [System.Text.Encoding]::UTF8.GetString($responseBytes)
    return $response
}

function Install-Software {

    if (!(Test-CommandAvailable "scoop")) {
        Write-Output $I18N_HELPER.parse("Scoop was not install, install scoop first")
        return 
    }
    
    $data = Get-Json-From-Url $SoftUrl
    
    #提示用户选择软件分组并进行安装
    $softwareGroups = $data.software_groups
    foreach ($idx in 0..($softwareGroups.Count - 1)) {
        $group = $softwareGroups[$idx]
        $groupSoftwareNames = foreach ($software in $group.software_list) {
            "{0}@{1}" -f $software.name, $software.version
        }
        $groupSoftwareNames = $groupSoftwareNames -join ","
        Write-Output "$idx. $($I18N_HELPER.parse($group.name)) - $groupSoftwareNames"
    }
    $groupIdx = Read-Host $I18N_HELPER.parse("main.INPUT_GROUP_NO")
    $selectedGroup = $softwareGroups[$groupIdx]
    
    #确认是否安装所选分组的所有软件
    $softwareToInstall = $selectedGroup.software_list
    for ($i = 0; $i -lt $softwareToInstall.Count; $i++) {
            Write-Progress -Activity "Installing Group Softs " -Status "Install... $($software.name)" -PercentComplete (($i / $softwareToInstall.Count) * 100)
        $software = $softwareToInstall[$i]
        $bucket = $software.bucket;
        $bucket_url = $software.bucket_url;
        $name = $software.name
        $version = $software.version

        Write-Progress -Activity "Installing Group Softs " -Status "Install... $($software.name)" -PercentComplete (($i / $softwareToInstall.Count) * 100)
        if($bucket.Contains("/")){
            $bucket = $bucket.split("/")[1]
        }
        Write-Output "Begin add bucket $bucket $bucket_url"
        scoop bucket add "$bucket" "$bucket_url"
        Write-Output "Begin install $name@$version"
        scoop install "$name@$version"
        Start-Sleep -Milliseconds 1000
    }
}


function Init-i18n {

    $languageMap = [ordered] @{
        "1" = @{
            "code" = "en"
            "name" = "English"
        }
        "2" = @{
            "code" = "zh_CN"
            "name" = "Chinese"
        }
    }
    
    Write-Output "Language:`n$('-' * 20)"
    $languageMap.GetEnumerator() | ForEach-Object { "{0}. {1}" -f $_.Name, $_.Value.name } | Write-Output 
    $choiceLanguage = Read-Host "Enter the number for your language choice"
    if (-not $choiceLanguage -or $choiceLanguage -notin $languageMap.Keys) {
        $choiceLanguage = "1"
    }
    $global:I18N_HELPER = Get-i18n-Helper ($I18N_URL -f $languageMap[$choiceLanguage]["code"])
}

$SCOOP_INSALL_SH_URL = "https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1"
# $SCOOP_INSALL_SH_URL = "http://ghproxy.com/https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/back/installscoop.speedup.ps1"
$I18N_URL = "https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/i18n/{0}.json"
# $I18N_URL = "http://ghproxy.com/https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/i18n/{0}.json"
$I18N_HELPER = ''


function Main {
    Init-i18n

    for (; ; ) {

        Log-ScoopVersion
        
        Write-Output ($I18N_HELPER.parse("main.INPUT_OPERATOR") + ":`n$('-' * 20)" )
        Write-Output ("1." + $I18N_HELPER.parse("main.INSTALL_SCOOP"))
        Write-Output ("2." + $I18N_HELPER.parse("main.INSTALL_SOFT"))
        Write-Output ("0." + $I18N_HELPER.parse("main.INSTALL_QUIT"))

        $choice = Read-Host $I18N_HELPER.parse("main.INSTALL_SOFT")

        # 根据用户的选择执行相应的操作
        switch ($choice) {
            "1" {
                Install-Scoop
            }
            "2" {
                Install-Software
            }
            "0" {
                exit 0
            }
            default {
                Write-Host $I18N_HELPER.parse("main.INVALID_INPUT")
            }
        }

    }

}

$ErrorActionPreference = 'Stop'

Main