function Replace-GitHubUrls {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputText,
        [Parameter(Mandatory = $true)]
        $UrlMap
    )


    # 替换 GitHub URLs
    $OutputText = $InputText 
    
    foreach ($key in $UrlMap.Keys) {
        $OutputText = $OutputText -replace $key, $UrlMap[$key]
    }
    return $OutputText

}