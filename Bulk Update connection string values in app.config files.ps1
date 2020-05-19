Function Set-ConnectionString{
	[CmdletBinding(SupportsShouldProcess=$True)]
	Param(
        [string]$fileName="app.config",
        [string]$connectionStringName,
        [string]$connectionString
    )

	$config = [xml](Get-Content -LiteralPath $fileName)

    $config.Configuration.appSettings

	$connStringElement = $config.SelectSingleNode("configuration/appSettings/add[@key='$connectionStringName']")

    if($connStringElement) {

        #$connStringElement.connectionString = $connectionString
        $connStringElement.Value = $connectionString

    	if($pscmdlet.ShouldProcess("$fileName","Modify app.config connection string")){
    		Write-Host ("Updating app.config connection string {0} to be {1}" -f $connectionStringName, $connectionString)

    		$config.Save($fileName)
    	}
    }
    else{
        Write-Error "Unable to locate connection string named: $connectionStringName"
    }
}
# Declare the data of Client name and Path for Renaming
$CUSTOMSpath="Path"
$configs=gci -Path $CUSTOMSpath -recurse -Filter '*.config'
#for each file in files list
ForEach($config in $configs)
{
# where the objuct name matches to Pattren run the rename  function
$configfiles = $config | Select-Object -ExpandProperty FullName
Set-ConnectionString "$configfiles" constr "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" Constr "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" connstring "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" ConnString "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" ConnString "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" BulkConnString "Data Source=;Initial Catalog=;User Id=;Password=;Persist Security Info=True;" 
Set-ConnectionString "$configfiles" DBName "" 
Set-ConnectionString "$configfiles" DBServer "" 
Set-ConnectionString "$configfiles" DBUN "" 
Set-ConnectionString "$configfiles" DBPWD "" 
}
