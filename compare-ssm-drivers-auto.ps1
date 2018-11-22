$work = $false

$ssmFolder = "D:\SSM"
$ssmBadDestination = "d:\temp\ssm"

Remove-Variable table

$id = 0
$cid = 0

$files = gci $ssmFolder -Recurse -Include "*.cva"

# Делаем индекс объектов

$table = foreach ($file in $files.FullName) { 

    New-Object "PSObject" -Property @{

    id = ($id++)
    Name = (Get-Content $file | % {$_ | where {$_ -match "US=" }})
    FullName = ($file)
    Version = (Get-Content $file | % {$_ | where {$_ -like "Version=*" }})
    sp =($file).replace(".cva","").replace("D:\SSM\sp","")
    }




}


Write-Host "Added $id"
Remove-Variable tableMoved
$cid = 0 
foreach ($index in $table) {
write-host ("id:" + $index.id + " cid:" + $cid)
$cid++

    foreach ($index2 in $table) {

        if (($index.FullName -ne $index2.FullName) -and ($index.name -eq $index2.name) -and ($tableMoved -notcontains $index.id)) {
            
            Write-Output ("index1: " + $index.FullName + " index2: " + $index2.FullName)
            

            Write-Output ("Found: " + ($index.id) + " " + ($index.version) + " and: "+ ($index2.id) + " " + ($index2.version))

            if ($index.sp -lt $index2.sp) { 
                
                Write-Host (($index.sp) + " is less than " + ($index2.sp))

                $fileToMove = ([io.path]::GetFileNameWithoutExtension($index.FullName)).replace(".cva","")

                if ($work) {
                gci $ssmFolder -Recurse -Include ($fileToMove + "*") | Move-Item -Destination $ssmBadDestination 
                } else {
                gci $ssmFolder -Recurse -Include ($fileToMove + "*") | Move-Item -Destination $ssmBadDestination -WhatIf
                }

                Write-Output ("Added " + $index.id)
                [array]$tableMoved += $index.id

               }

            Write-Output ("Done: " + ($tableMoved | sort))      
            

        }

    }
}

$tableMoved.count 