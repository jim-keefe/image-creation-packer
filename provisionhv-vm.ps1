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
Header -message "Read in State JSON" -level 2
#======================================

$basepath = "E:\Hyper-V"
if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = [pscustomobject](Get-Content -Path $jsonPath | ConvertFrom-Json) }

"vmname : $($env:BUILD_TAG)"
"vmname : $($oState.vmname)"
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

if ($createVM){ Set-VMProcessor -VMName $VMName -Count $ProcessorCount }

Start-VM -Name $VMName

#======================================
Header -message "Save State to JSON" -level 2
#======================================


Add-Member -InputObject $oState -Name "vmname" -Value $VMName -MemberType NoteProperty
Add-Member -InputObject $oState -Name "vhdxtemplatepath" -Value $vhdxTemplatePath -MemberType NoteProperty

set-content -Value $(ConvertTo-Json -InputObject $oState) -Path $jsonPath
