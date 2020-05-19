# Keeps latest 2 files from a directory based on Creation Time

#Declaration variables
$path = "Path"                               # For example $path= C:\log\*.tmp
$total= (ls $path).count - 2 # Change number 2 to whatever number of objects you want to keep
# Script
ls $path |sort-object -Property {$_.CreationTime} | Select-Object -first $total | Remove-Item -force
