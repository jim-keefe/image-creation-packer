param (
    $vmName = "win-$(Get-Date -Format yyyyMMddhhmmssfff)",
    $vhdxTemplatePath = "E:\Hyper-V\Templates\win2022\Virtual Hard Disks\packer-windows-server-2022.vhdx",
    $hyperVVMPath = "E:\Hyper-V\VirtualMachines",
    $switchName = "External Switch Wireless",
    $generation = 1,
    $memory = (2*1024*1024*1024),
    $processorCount = 2,
    $remoteuser = "Administrator",
    $remotepass = "packer",
    $createVM = $true
    )

# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\provisionhv-functions.ps1"

$secstr = New-Object -TypeName System.Security.SecureString
$remotepass.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $remoteuser, $secstr

#======================================
Write-Output "Read in State JSON"
#======================================

$basepath = "E:\Hyper-V"
if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = [pscustomobject](Get-Content -Path $jsonPath | ConvertFrom-Json) }

"buildtag : $($env:BUILD_TAG)"
"vmname : $($vmName)"
#======================================
Write-Output "Create Folder Structure"
#======================================

ValidateCreateFolder -path "$hyperVVMPath\$vmName\Virtual Hard Disks"

#======================================
Write-Output "Copy the template vhdx"
#======================================

$vhdxDest = "$hyperVVMPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
Copy-Item -Path $vhdxTemplatePath -Destination $vhdxDest

#======================================
Write-Output "Create the VM"
#======================================


$vmCreate = @{
    Name = $vmName
    VHDPath = $vhdxDest
    Path = $hyperVVMPath
    MemoryStartupBytes = $memory
    Generation = $generation
    BootDevice = "VHD"
    switchName = $SwitchName
}

if ($createVM){ New-VM @vmCreate }

#======================================
Write-Output "Set the number of processors"
#======================================

if ($createVM){ Set-VMProcessor -VMName $VMName -Count $ProcessorCount }

Start-VM -Name $VMName

#======================================
Write-Output "Save State to JSON"
#======================================

Write-Output "Check Hyper-V for vm IP"
for ( $i = 1 ; $i -le 120 ; $i++){
    $tempvm = get-vm -Name $VMName
    if ($tempvm.NetworkAdapters[0].IPAddresses[0]) {
        $ip = $tempvm.NetworkAdapters[0].IPAddresses[0]
        Write-Output "Found IP ($ip)"
        Add-Member -InputObject $oState -Name "ip" -Value $tempvm.NetworkAdapters[0].IPAddresses[0] -MemberType NoteProperty
        $i = 10000
    } else {
        Write-Output "Waiting for IP ($i)"
        start-sleep 1
    }
}

Write-Output "Check for Hyper-V remote shell interface"
for ( $i = 0 ; $i -le 120 ; $i = $i + 5){
    $result = Invoke-Command -vmname $VMName -Credential $cred -ScriptBlock {return $env:COMPUTERNAME} -ErrorAction SilentlyContinue
    if ($result) {
        Write-Output "Hyper-V console connection: Success (hostname: $result)"
        Add-Member -InputObject $oState -Name "hostname" -Value $result.trim() -MemberType NoteProperty
        $i = 10000
    } else {
        Write-Output "Waiting to connect to Hyper-V vm ($i)"
        start-sleep 5
    }
}

Add-Member -InputObject $oState -Name "vmname" -Value $VMName -MemberType NoteProperty
Add-Member -InputObject $oState -Name "vhdxtemplatepath" -Value $vhdxTemplatePath -MemberType NoteProperty

Write-Output "Write Vars to JSON"
set-content -Value $(ConvertTo-Json -InputObject $oState) -Path $jsonPath