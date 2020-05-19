function getservice {
param(
 [string]$term
 )

 $term = "app" + $term + "*"
 Get-Service |select name,StartType,status| Where-Object {($_.Name -like "$term" -or $_.DisplayName -like "$term") }  #| out-file  C:\Report.txt
 }

 getservice | Out-File C:\ServiceMonitor.txtfunction getservice {
param(
 [string]$term
 )

 $term = "app" + $term + "*"
 Get-Service |select name,StartType,status| Where-Object {($_.Name -like "$term" -or $_.DisplayName -like "$term") }  #| out-file  e:\Report.txt
 }

 getservice | Out-File C:\ServiceMonitor.txt
