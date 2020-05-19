Function  generaterp{
$outtable = @()
$users = (Get-WmiObject win32_ComputerSystem ).UserName#.Split('\')[1]
$users | % {
  $x =  Get-WmiObject win32_operatingsystem | select CSName, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
  $t = New-Object PSObject -Property @{
    Username = $users
    computername = $x.csname
    LastBootUpTime = $x.Lastbootuptime
  }
  
  $outtable += $t

}

$outtable | select computername,username,Lastbootuptime |export-csv "$env:temp\report.csv" -nti
#####################################################
# get public ip address and 10 hops ping response 

 #$ping = Test-Connection 8.8.8.8 | Select IPV4Address, ResponseTime, @{N="Date";E={Get-Date}} | format-Table -autosize|out-file -append "$env:temp\ITreport.csv"
 $ping = ping 8.8.8.8 -n 10 | format-Table -autosize|out-file -append "$env:temp\report.csv"
 $pip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip|out-file -append "$env:temp\report.csv"
 $vping = ping 4.4.2.2 | format-Table -autosize|out-file -append "$env:temp\Ireport.csv"
 ###################################################
 # set password protected

 function Release-Ref ($ref) { 
([System.Runtime.InteropServices.Marshal]::ReleaseComObject( 
[System.__ComObject]$ref) -gt 0) 
[System.GC]::Collect() 
[System.GC]::WaitForPendingFinalizers()  
} 
add-type -AssemblyName Microsoft.Office.Interop.Excel
$xlNormal = -4143
$excel = new-object -comobject excel.application
$excel.Visible=$true
$file = get-item "$env:temp\report.csv"
$workbook = $excel.workbooks.open($file)
$workbook.SaveAs("$($env:USERPROFILE)\Desktop\Report.csv",$xlNormal,"Password") 
$Excel.Workbooks.Close()
$excel.Quit()
Start-Sleep -s 1
#sp "$($env:USERPROFILE)\Desktop\ip\Report.csv" Isreadonly $false 
####################################################
 #email configuration
 $from_address = ""
 $to_address= ""
 $email_gateway=""
 $port = 
 $smtp_user = "" 
 $smtp_pass = ''
 $mail= New-Object System.Net.Mail.MailMessage
 $mail.From = $from_address
 $mail.To.Add($to_address)
 $mail.Subject ="System Diagnosis Status report"
 $mail.Body= "**System Diagnosis Report**"
 $Attachment = "$($env:USERPROFILE)\Desktop\Report.csv"
 $mail.Attachments.Add($Attachment) 
 $smtp = New-Object System.Net.Mail.SmtpClient($email_gateway,$port)
 $smtp.Credentials = New-Object System.Net.NetworkCredential($smtp_user,$smtp_pass)
 $smtp.EnableSsl = $true 
 $smtp.Send($mail)
 $smtp.Dispose()
 $mail.Dispose()
 }
 generaterp
 Remove-Item -Force -Recurse -path "$($env:USERPROFILE)\Desktop\Report.csv"

                 
