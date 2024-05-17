Import-Module /src/Modules/Polaris
Import-Module /src/Modules/SqlServer

$sqlUserName = $env:SQLUSERNAME
$sqlPassword = $env:SQLPASSWORD
$sqlHost = $env:SQLHOST
$sqlDatabase = $env:SQLDATABASE

New-PolarisRoute -Path "/api/AverageAttDiff" -Method GET -Scriptblock {
    $query = 'exec usp_getaverageAttDiff'
    $data = Invoke-Sqlcmd -ServerInstance $sqlHost -Database $sqlDatabase -Username $sqlUserName -Password $sqlPassword -Query $query -TrustServerCertificate
    $Response.Json(($data | select personName, avgCheckInDiff | ConvertTo-Json))
}

 New-PolarisRoute -Path "/api/person/:id" -Method GET -Scriptblock {
     $personName = $Request.Parameters.id
     $personName = $personName.Replace('%20',' ')
     $query = "exec USP_GetUserAverageAttDiff '" + $personName + "'"
     $data = Invoke-Sqlcmd -ServerInstance $sqlHost -Database $sqlDatabase -Username $sqlUserName -Password $sqlPassword -Query $query -TrustServerCertificate
     if($data.Count -eq 0) {
         $Response.SetStatusCode(404)
         $Response.Send("Person $($Request.Parameters.id) not found!")
     }
     else {
         $Response.Json(($data | select personName, avgCheckInDiff | ConvertTo-Json))
     }    
 }

$app = Start-Polaris -Port 8082 -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware -Verbose # all params are optional

while($app.Listener.IsListening){
    Wait-Event callbackcomplete
}
