param (
    $vmName = "win-$(Get-Date -Format yyyyMMddhhmmssfff)",
    $vhdxTemplatePath = "E:\Hyper-V\Templates\win2022\Virtual Hard Disks\packer-windows-server-2022.vhdx",
    $hyperVVMPath = "E:\Hyper-V\VirtualMachines",
    $switchName = "External Switch Wireless",
    $generation = 1,
    $memory = (2*1024*1024*1024),
    $processorCount = 2,
    $createVM = $true
    )

# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\provisionhv-functions.ps1"

#======================================
Header -message "Create Folder Structure" -level 2
#======================================

ValidateCreateFolder -path "$hyperVVMPath\$vmName\Virtual Hard Disks"

#======================================
Header -message "Copy the template vhdx" -level 2
#======================================

$vhdxDest = "$hyperVVMPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
Copy-Item -Path $vhdxTemplatePath -Destination $vhdxDest

#======================================
Header -message "Create the VM" -level 2
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
Header -message "Set the number of processors" -level 2
#======================================
$createVM
if ($createVM){ Set-VMProcessor -VMName $VMName -Count $ProcessorCount }

Start-VM -Name $VMName