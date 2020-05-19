import-module webadministration
$app= Get-content -path "path\app.txt"
function Set-WebsiteAppPoolCustomIdentity([String] $appPoolName, [String] $userId, [String] $pwd)
{  
    Write-Host $appPoolName;
    $webAppPool = get-item IIS:\AppPools\$appPoolName     
    $webAppPool.processModel.userName = $userId;
    $webAppPool.processModel.password = $pwd;
    $webAppPool.processModel.identityType = 3;
    $webAppPool | Set-Item
    $webAppPool.Stop();
    Start-Sleep -s 10
    $webAppPool.Start();
    Write-Host "Apppool Recycled";
    $webAppPool = get-item iis:\apppools\$appPoolName;
    #write-host "New Pool User: " $webAppPool.processModel.userName;
    #write-host "New Pool PWd: " $webAppPool.processModel.password;
}
Set-ExecutionPolicy bypass
$Users= Get-content -path "path\users.txt"
$Currentuser= [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
foreach( $user in $Users)
{
if($Currentuser -eq $user)
{
Set-WebsiteAppPoolCustomIdentity  -appPoolName "$app" -userId "user" -pwd 'password'
}
else
{
Write-Warning "$Currentuser you are not authorized"
}
}
