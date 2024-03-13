$dlDestination = "$($env:windir)\temp\dotnet.4.8.exe"
$os = (Get-CimInstance Win32_OperatingSystem).Caption
if ($os -like "*2019*"){
    Write-Output "Downloading 4.8 on $os"
    Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=2088631" -OutFile $dlDestination # Download from MS
    if (Test-Path $dlDestination){
        Write-Output "Installing 4.8 on $os"
        Start-Process $dlDestination -ArgumentList "Setup /q /norestart /log $($env:windir)\temp\" -Wait
        Write-Host "Installed 4.8 $LASTEXITCODE"
    } else {
        Write-Output "$dlDestination NOT FOUND"
        Start-Sleep 60
        throw "$dlDestination NOT FOUND"
    }
} else {
    Write-Output "Skipping Install 4.8 on $os"
}

Start-Sleep 15