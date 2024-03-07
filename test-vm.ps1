param (
    $hyperVVMPath = "E:\Hyper-V\VirtualMachines",
    $test = "ping",
    $remoteuser = "Administrator",
    $remotepass = "packer",
    $jenkinsbuildtag = $null
    )

$secstr = New-Object -TypeName System.Security.SecureString
$remotepass.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $remoteuser, $secstr

$basepath = "E:\Hyper-V"
if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = Get-Content -Path $jsonPath | ConvertFrom-Json }

$tempvm = get-vm $oState.vmname

Write-Output "Perform $test test"
switch ($test){
    "vmstatus" {
        if ($tempvm.status -like "Operating Normally"){Write-Output "$test : passed"} else {throw "$test : failed"}
    }
    "ip" {
        if ($ip -like "*.*.*.*"){Write-Output "$test : passed"} else {throw "$test : failed"}
    }
    "WINRM" {
        $result = (Test-NetConnection -vmname $IP -CommonTCPPort WINRM).TcpTestSucceeded
        if ($result){Write-Output "$test : passed"} else {throw "$test : failed"}
    }
    "python" {
        $result = Invoke-Command -vmname $oState.vmname -Credential $cred -ScriptBlock {cmd /c python --version} -ErrorAction SilentlyContinue
        if ($result -like "*3.12.2") { Write-Output "$test : passed" } else { Write-Output "$test : failed" }
    }
    "git" {
        $result = Invoke-Command -vmname $oState.vmname -Credential $cred -ScriptBlock {cmd /c git --version}
        if ($result -like "git version 2.44.0.windows.*") {Write-Output "$test : passed"} else {throw "$test : failed"}
    }
    "sysinternals" {
        $result = Invoke-Command -vmname $oState.vmname -Credential $cred -ScriptBlock {Test-Path "C:\ProgramData\chocolatey\bin\junction.exe"}
        if ($result){Write-Output "$test : passed"} else {throw "$test : failed"}
    }
    "bginfo" {
        $result = Invoke-Command -vmname $oState.vmname -Credential $cred -ScriptBlock {Test-Path "C:\ProgramData\chocolatey\bin\bginfo64.exe"}
        if ($result){Write-Output "$test : passed"} else {throw "$test : failed"}
    }
}
