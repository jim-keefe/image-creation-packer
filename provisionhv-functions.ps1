function ValidateCreateFolder {

    param (
        $path,
        $failiffound = $false
    )

    If(!(test-path -PathType container $path))
    {
        Logupdate -message "$path path not found"
        Logupdate -message "Creating path $path"
        New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue
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