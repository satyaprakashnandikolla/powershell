param (
    $sessionUrl = "sftp://user:pwd;fingerprint=fingerprint@hostid/",
    $remotePath = "/",
    $outFile = "$env:temp\SFTPlisting.txt",
    $remotePath1 = "/L1/"

)
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.ParseUrl($sessionUrl)
 #$sessionOptions = New-Object WinSCP.
    try
    {
        # Connect
        Write-Host "Connecting..."
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
#function to get data

        function Get-WinScpChildItem ($WinScpSession, $BasePath) {

#Get the directory listing
$Directory = $WinScpSession.ListDirectory($BasePath)

#Initialize an empty collection
$MyCollection = @()


function Get-FriendlySize {
    param($Bytes)
    $sizes='Bytes,KB,MB,GB,TB,PB,EB,ZB' -split ','
    for($i=0; ($Bytes -ge 1kb) -and 
        ($i -lt $sizes.Count); $i++) {$Bytes/=1kb}
    $N=2; if($i -eq 0) {$N=0}
    "{0:N$($N)} {1}" -f $Bytes, $sizes[$i]
}
#Browse through each entry
foreach ($DirectoryEntry in $Directory.Files) {

#We want to ignore . and .. folders
if (($DirectoryEntry.Name -ne '.') -and ($DirectoryEntry.Name -ne '..')) {

#Initialize an object to which we will add custom properties. You can add all properties you may need later such as Last Write Time etc
        $TempObject = New-Object System.Object

          $dir= $DirectoryEntry.LastWriteTime

          $size = $DirectoryEntry.Length
        #$Filesize = [math]::round($size/1KB, 3)
     $Filesize =    Get-FriendlySize -Bytes $size
        
#If the current entry is a directory, we need to add it to our collection, as a directory, then recurse
        if ($DirectoryEntry.IsDirectory) {

#We need to save the BasePath before recursing
            $SavePath = $BasePath
            #$savepath
#Special case : Avoid adding an extraneous '/' if we are at the root directory
            if ($BasePath -eq '/') {
              If ($BasePath -eq '//'){
            $BasePath += "/$($DirectoryEntry.Name)"
            }
            Else {
            $BasePath += "$($DirectoryEntry.Name)"
            }
                
                #$basepath
# save path in a new variable and do list directory method
        $Path= $BasePath
 
            # Collect file list
            $files =
                $session.EnumerateRemoteFiles(
                    $Path, "*.*", [WinSCP.EnumerationOptions]::None) |
                Select-Object -ExpandProperty FullName

         $Folder= "FilesCount:"+ $($files.Count)


                }
            else {
                $BasePath += "/$($DirectoryEntry.Name)"
               # $basepath
               $Path= $BasePath

 
            # Collect file list
            $files =
                $session.EnumerateRemoteFiles(
                    $Path, "*.*", [WinSCP.EnumerationOptions]::None) |
                Select-Object -ExpandProperty FullName

         $Folder= "FilesCount:"+ $($files.Count)
                }
                
            $TempObject | Add-Member -MemberType NoteProperty -name 'Name' -Value $BasePath
            $TempObject | Add-Member -MemberType NoteProperty -name 'IsDirectory' -Value $true
            $TempObject | Add-Member -MemberType NoteProperty -name 'LastAccessTime' -Value $dir
            $TempObject | Add-Member -MemberType NoteProperty -name 'Size & File Count' -Value $Folder          
            $MyCollection += $TempObject

#Now we recurse, and when done, we reset the BasePath
            $MyCollection += Get-WinScpChildItem $WinScpSession $BasePath
            $BasePath = $SavePath
            }

#If the current entry is a file, it's time to add it to our collection, as a file

        else {
            $TempObject | Add-Member -MemberType NoteProperty -name 'Name' -Value "$BasePath/$DirectoryEntry"
            $TempObject | Add-Member -MemberType NoteProperty -name 'IsDirectory' -Value $false
            $TempObject | Add-Member -MemberType NoteProperty -name 'LastAccessTime' -Value $dir
            $TempObject | Add-Member -MemberType NoteProperty -name 'Size & File Count' -Value $Filesize         
            
            $MyCollection += $TempObject

             }
        }
    }

#The function finally returns the collection
return $MyCollection
}

# function calling

  Get-WinScpChildItem -WinScpSession $Session -BasePath $remotePath | Out-File -Append $outFile -Width 1000

# find count of particular Directory
            # Collect file list
            $files =
                $session.EnumerateRemoteFiles(
                    $remotePath1, "*.*", [WinSCP.EnumerationOptions]::None) |
                Select-Object -ExpandProperty FullName
                # In the first round, just print number of files found
                $fc=$($files.Count)

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
 $mail.Subject ="SFTP Status report File count in L1 Directory: $fc "
 $mail.Body= "** SFTP Report**"
 $Attachment = "$env:temp\SFTPlisting.txt"
 $mail.Attachments.Add($Attachment) 
 $smtp = New-Object System.Net.Mail.SmtpClient($email_gateway,$port)
 $smtp.Credentials = New-Object System.Net.NetworkCredential($smtp_user,$smtp_pass)
 $smtp.EnableSsl = $true 
 $smtp.Send($mail)
 $smtp.Dispose()
 $mail.Dispose()
 Write-Host "Email Sent"
 Remove-Item -Force -Recurse -path "$env:temp\SFTPlisting.txt"
 
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}

