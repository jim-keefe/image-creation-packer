param (
    $vmName = "win-$((New-Guid).guid)",
    $vhdxTemplatePath = "E:\output-windows-server-2022\Virtual Hard Disks\packer-windows-server-2022.vhdx",
    $hyperVVMPath = "E:\VirtualMachines",
    $switchName = "External Switch Wireless",
    $generation = 1,
    $memory = (2*1024*1024*1024),
    $processorCount = 2,
    $createVM = $true
    )

$vhdxName = (Get-Item $vhdxTemplatePath).Name

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

Copy-Item -Path $vhdxTemplatePath -Destination "$hyperVVMPath\$vmName\Virtual Hard Disks\$vhdxName"

#======================================
Header -message "Create the VM" -level 2
#======================================


$vmCreate = @{
    Name = $vmName
    VHDPath = "$hyperVVMPath\$vmName\Virtual Hard Disks\$vhdxName"
    Path = $hyperVVMPath
    MemoryStartupBytes = $memory
    Generation = $generation
    BootDevice = "VHD"
    switchName = $SwitchName
}

$vmCreate | select *
if ($createVM){ New-VM @vmCreate }

#======================================
Header -message "Set the number of processors" -level 2
#======================================
$createVM
if ($createVM){ Set-VMProcessor -VMName $VMName -Count $ProcessorCount }

Start-VM -Name $VMName