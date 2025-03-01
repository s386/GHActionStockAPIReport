

param (
    [string]$api_token
)

$apiEndpoint = "https://api.stockdata.org/v1/data/quote"

$sybmols=@()

$sb = new-object -TypeName "System.Text.StringBuilder"

$sb.AppendLine("apiKey is [$($api_token)]")

#Read in sybmols file
try 
{
    $fnSymbols=[System.IO.Path]::Combine($PSScriptRoot,"stock_symbols.txt") 
    $lines = [System.IO.File]::ReadAllLines($fnSymbols)
    foreach($curLine in $lines)
    {
        if($curLine.Trim().Length -gt 0)
        {
            $symbols+=$curLine.Trim()
        }
    }    
}
catch 
{
    <#Do this if a terminating exception happens#>
}

$res = ""
if($symbols.Count -eq 0)
{
    $res="No sybmols requested"
}
else 
{
    $url = "$($apiEndpoint)?api_token=$($api_token)&symbols=$($symbols[0])"
    try 
    {
        $response = Invoke-RestMethod -Uri $url -Method Get
        $res="$($sybmols[0])-->$($response.data[0].price)"
    }
    catch 
    {
        $res="Exception: $($_.Exception.Message)"
    }
}

#get subfolder
$fol = [System.IO.Path]::Combine($PSScriptRoot,"output")
if(-not ([System.IO.Directory]::Exists($fol)))
{
    [System.IO.Directory]::CreateDirectory($fol)
}

$finalLine="$([datetime]::Now.ToString("yyyy-MM-dd HH:mm:ss"))-->$res`r`n)"

$sb.AppendLine($finalLine)

$fnOut="$([System.IO.Path]::Combine($fol,"stock_price_log.txt"))"
[System.IO.File]::AppendAllText($fnOut,$sb.ToString())