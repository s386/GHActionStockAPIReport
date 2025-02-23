
$apiEndpoint = "https://api.stockdata.org/v1/data/quote"
$api_token = "s79HUKK2cS1DgJW5B9O8BqUPrx92abLMBc0yrsbq"
$sybmols=@()


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
$fnOut="$([System.IO.Path]::Combine($fol,"stock_price_log.txt"))"
[System.IO.File]::AppendAllText($fnOut,$finalLine)