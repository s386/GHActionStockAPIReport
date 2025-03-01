

param (
    [string]$apikey
)

$apiEndpoint = "https://api.stockdata.org/v1/data/quote"

$symbols=@()

$sb = new-object -TypeName "System.Text.StringBuilder"

# this was just for debug
#$sb.AppendLine("apiKey is [$($apikey)]")

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

$summary = "NumSymbols: $($symbols.Count)";
foreach($s in $symbols)
{
    $summary+="[$s]"
}

$sb.AppendLine("NumSymbols: $summary")

$res = ""
foreach($s in $symbols)
{
    $url = "$($apiEndpoint)?api_token=$($apikey)&symbols=$($s)"
    try 
    {
        $response = Invoke-RestMethod -Uri $url -Method Get
        $res+=="[$($s)] $($response.data[0].price)  "
    }
    catch 
    {
        $res+="Exception: Error retrieving price for $($s): $($_.Exception.Message)"
    }
}

#get subfolder
$fol = [System.IO.Path]::Combine($PSScriptRoot,"output")
if(-not ([System.IO.Directory]::Exists($fol)))
{
    [System.IO.Directory]::CreateDirectory($fol)
}

$finalLine="$([datetime]::Now.ToString("yyyy-MM-dd HH:mm:ss"))-->$res"

$sb.AppendLine($finalLine)

$fnOut="$([System.IO.Path]::Combine($fol,"stock_price_log.txt"))"
[System.IO.File]::AppendAllText($fnOut,$sb.ToString())