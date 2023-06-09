


Import-Module -Name sqlite
# Import-Module -Name PSSQLite

. "$PSScriptRoot/common.ps1"

function Get-AppByName {
    param ([string]$Query)
    $oSQLiteDBConnection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $oSQLiteDBConnection.ConnectionString = "Data Source=$Database"
    $oSQLiteDBConnection.Open()
    $oSQLiteDBCommand = $oSQLiteDBConnection.CreateCommand()
    $oSQLiteDBCommand.Commandtext = $Query
    $oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
    $oDBReader = $oSQLiteDBCommand.ExecuteReader()
    $Result = New-Object System.Collections.ArrayList

    if ($oDBReader.HasRows) {
        while ($oDBReader.Read()) {
            $res = [ordered]@{
                "name"        = $oDBReader["name"]
                "version"     = $oDBReader["version"]
                "bucket_url"  = $oDBReader["bucket_url"]
                "description" = $oDBReader["description"]
                "bucket"      = $oDBReader["bucket"]
            }
            $Result.Add($res) | Out-Null
        }
    }
    $oDBReader.Close()
    $oSQLiteDBConnection.Close()
    return $Result
}



# function Refresh-CommandAvailable {
#     if (![Boolean](Get-Command "scoop" -ErrorAction Ignore)) {
#         $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
#         Write-Output "Refresh PATH success"
#     }
#     else {
#         Write-Output "Scoop has installed, cancel Refresh PATH"
#     }
# }

$Database = "$env:USERPROFILE\scoop_directory.db" 
$SOFT_GROUP_DEFINE_PATH = "$PSScriptRoot/../soft_group_define.json"
$SOFT_GROUP_FILE_PATH = "$PSScriptRoot/../dist/group.json"

function Pre-Test {
    if (!(Test-Path $Database)) {
        Write-Output "$Database was not exist "
        exit 1;
    }
}

function Main {


    Pre-Test

    # Refresh-CommandAvailable

    # Convert the JSON to a PowerShell object
    $obj = Get-Content -Path $SOFT_GROUP_DEFINE_PATH -Encoding UTF8 | ConvertFrom-Json


    # Create an empty array to hold the software groups
    $softwareGroups = @{}

    # Loop through each software item in the original list
    foreach ($item in $obj.software_list) {


        if($item.name.Contains("@")){
            $nameAndVersion = $item.name.split("@");
            $name = $nameAndVersion[0]
            $version = $nameAndVersion[1]
        }else{
            $name = $item.name
        }

        $QueryString = 
        "SELECT
        apps.*, 
        buckets.stars
    FROM
        apps
        INNER JOIN
        buckets
        ON 
            apps.bucket_id = buckets.id
    WHERE
        apps.name = `'$($name)`'"

        if($version){
            $QueryString +=
            "
            and apps.version=`'$($version)`'
            
            "
        }

        $QueryString +=
        "    ORDER BY
        apps.version DESC, 
        buckets.stars DESC"

        $soft_info = (Get-AppByName $QueryString)  | Select-Object -First 1

        if (-not $soft_info) { 
            Write-Output ("Soft {0} not exist, skip" -f $name);
        }else{
            foreach ($itemGroups in $item.groups) {
                $existSoftGroup = $softwareGroups[$itemGroups];
                if (!$existSoftGroup) {
                    $existSoftGroup = @{
                        "name"          = $itemGroups
                        "software_list" = @()
                    }
                    $softwareGroups[$itemGroups] = $existSoftGroup;
                }
    
                $existSoftGroup.software_list += @{
                    "name"       = $name
                    "version"    = $soft_info.version
                    "bucket"     = $soft_info.bucket
                    "bucket_url" = $soft_info.bucket_url
                }
            }
        }
        $nameAndVersion = $null
        $name = $null
        $version = $null
    }

    # Create a new object containing the transformed data
    $res = @{
        "metadata"        = @{
            "type"         = "group"
            "last_updated" = (get-date -f "yyyy/MM/dd hh:mm:ss tt")
            "version"      = $obj.metadata.version
        }
        "software_groups" = $softwareGroups.Values
    } | ConvertTo-Json -Depth 5 -Compress

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($SOFT_GROUP_FILE_PATH, $res, $Utf8NoBomEncoding)
    Write-Output ("Write Files [{0}] done" -f $SOFT_GROUP_FILE_PATH)
}

Main