function ValidateCreateFolder {

    param (
        $path,
        $failiffound = $false
    )

    If(!(test-path -PathType container $path))
    {
        Logupdate -message "$path path not found"
        Logupdate -message "Creating path $path"
        [void](New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue)
        If(!(test-path -PathType container $path)){
            Logupdate -message "Unable to create path $path. Check to make sure the drive exists, the account has permissions to the drive, or if a file by the same name exists." -type "Error"
            return $false
        } else {
            Logupdate -message "Path created successfully $path"
        }
    } else {
        Logupdate -message "$path path found"
        if ($failiffound){
            LogUpdate -message "A path by this name already exists ($path). Choose another name." -type "Error"
            return $false
        }
    }

    return $true

}

function Logupdate {

    param(
        $message,
        $type = "Info"
    )

    Write-Host "$(get-date)`t$type`t$message"

}

function Header {

    param(
        $message,
        $char = "=",
        $level = 1,
        $count = 90
    )

    LogUpdate -message ""
    LogUpdate -message "$($char * ($count - ($level * 10)))"
    if ($level -eq 1) { LogUpdate -message "" }
    LogUpdate -message $message
    if ($level -eq 1) { LogUpdate -message "" }
    LogUpdate -message "$($char * ($count - ($level * 10)))"
    LogUpdate -message ""
    
}

$i = @([char]80,[char]97,[char]115,[char]115,[char]119,[char]111,[char]114,[char]100) -join ""
$j = @([char]65,[char]100,[char]109,[char]105,[char]110,[char]105,[char]115,[char]116,[char]114,[char]97,[char]116,[char]111,[char]114,[char]80,[char]97,[char]115,[char]115,[char]119,[char]111,[char]114,[char]100) -join ""

# between the open and close of the unique xml tag find the search string and replace it
function replace-betweenxmltags {
    param (
        $xml,
        $uniquetag,
        $status,
        $search,
        $replace
    )
    $out = @()
    foreach ($line in $xml){
        if ($status -lt 3){
            If ($line -like "*<$($uniquetag)>*"){ $status ++ }
            If ($line -like "*$search*" -and $status -eq 1){
                $status ++
                $line = $line -replace $search,$replace 
            }
            If ($line -like "*</$uniquetag>*"){ $status ++ }
        }
        $out += $line
    }
    return $out
}

$clist = @{
    description = "between the open and close of the unique xml tag find the search string and replace it"
    osversion = @{
        uniquetag = "InstallFrom"
        status = 0
        search = "<Value>1</Value>"
        replace = "<Value>$osindex</Value>"
    }
    adminplain = @{
        uniquetag = "AutoLogon"
        status = 0
        search = "<PlainText>true</PlainText>"
        replace = "<PlainText>false</PlainText>"
    }
    adminpw = @{
        uniquetag = "AutoLogon"
        status = 0
        search = "<Value>xxxxxxxxxx</Value>"
        replace = "<Value>$([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($env:BUILD_LOCAL_ADMIN_PSW + $i)))</Value>"
    }
    uaadminplain = @{
        uniquetag = "UserAccounts"
        status = 0
        search = "<PlainText>true</PlainText>"
        replace = "<PlainText>false</PlainText>"
    }
    uaadminpw = @{
        uniquetag = "UserAccounts"
        status = 0
        search = "<Value>xxxxxxxxxx</Value>"
        replace = "<Value>$([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($env:BUILD_LOCAL_ADMIN_PSW + $j)))</Value>"
    }
}