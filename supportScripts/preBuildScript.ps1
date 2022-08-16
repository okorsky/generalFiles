$loc = (get-location).Path
set-content -path "C:\dev\fwpslogpath.txt" -value "loc: $loc"
set-content -path "C:\dev\fwpslogrepname.txt" -value "rep name: $env:REPONAME"      
set-content -path "C:\dev\fwsecret2.txt" -value "$env:SECRET"
$myFilePath = "$env:REPONAME" + "\Resources\myFile.txt"      
$joinPath = Join-Path -Path $loc -ChildPath $myFilePath
set-content -path "C:\dev\fwjoinedPath.txt" -value $joinPath      
set-content -path $joinPath -value "modified from pipeline script file"