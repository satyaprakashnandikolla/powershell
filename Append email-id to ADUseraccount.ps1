Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase 'DC=domain,DC=domain' | `
    ForEach-Object { Set-ADUser -EmailAddress ($_.samaccountname + '@domaint.com') -Identity $_ }
