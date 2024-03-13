param (
    $vmName = "win-$(Get-Date -Format yyyyMMddhhmmssfff)",
    $switchName = "External Switch Wireless",
    $generation = 1,
    $memory = (2*1024*1024*1024),
    $processorCount = 2,
    $remoteuser = "Administrator",
    $remotepass = "$($env:BUILD_LOCAL_ADMIN_PSW)",
    $createVM = $true
    )

# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\pipeline-functions.ps1"

$secstr = New-Object -TypeName System.Security.SecureString
$remotepass.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $remoteuser, $secstr

#================================================================
Write-Output "Read in State JSON"
#================================================================

$basepath = $env:BASE_HYPERV_PATH
if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = [pscustomobject](Get-Content -Path $jsonPath | ConvertFrom-Json) }
$vhdxTemplatePath = "$basePath\Templates\Win$($oState.osYear)$($oState.osSelect)\Virtual Hard Disks\packer-Win$($oState.osYear)$($oState.osSelect).vhdx"
$hyperVVMPath = "$basePath\VirtualMachines"

#================================================================
Write-Output "Create Folder Structure"
#================================================================

ValidateCreateFolder -path "$hyperVVMPath\$vmName\Virtual Hard Disks"

#================================================================
Write-Output "Copy the template vhdx"
#================================================================

$vhdxDest = "$hyperVVMPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
Copy-Item -Path $vhdxTemplatePath -Destination $vhdxDest

#================================================================
Write-Output "Create the VM"
#================================================================

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

#================================================================
Write-Output "Set the number of processors"
#================================================================

if ($createVM){ Set-VMProcessor -VMName $VMName -Count $ProcessorCount }
Start-VM -Name $VMName

#================================================================
Write-Output "Check Hyper-V for vm IP"
#================================================================

for ( $i = 1 ; $i -le 120 ; $i++){
    $tempvm = get-vm -Name $VMName
    if (($tempvm.NetworkAdapters[0].IPAddresses[0]) -and ($tempvm.NetworkAdapters[0].IPAddresses[0]) -notlike "169.*.*.*"){
        $ip = $tempvm.NetworkAdapters[0].IPAddresses[0]
        Write-Output "Found IP ($ip)"
        Add-Member -InputObject $oState -Name "ip" -Value $tempvm.NetworkAdapters[0].IPAddresses[0] -MemberType NoteProperty
        $i = 10000
    } else {
        Write-Output "Waiting for IP ($i)"
        start-sleep 1
    }
}

#================================================================
Write-Output "Check for Hyper-V remote shell interface on $vmname"
#================================================================

for ( $i = 0 ; $i -le 120 ; $i = $i + 5){
    $result = Invoke-Command -vmname $VMName -Credential $cred -ScriptBlock {return $env:COMPUTERNAME} -ErrorAction SilentlyContinue
    if ($result) {
        Write-Output "Hyper-V console connection: Success (hostname: $result)"
        Add-Member -InputObject $oState -Name "hostname" -Value $result.trim() -MemberType NoteProperty
        $i = 10000
    } else {
        Write-Output "Waiting to connect to Hyper-V test vm ($i)"
        start-sleep 5
    }
}

#================================================================
Write-Output "Save State to JSON"
#================================================================

Add-Member -InputObject $oState -Name "vmname" -Value $VMName -MemberType NoteProperty
Add-Member -InputObject $oState -Name "vhdxtemplatepath" -Value $vhdxTemplatePath -MemberType NoteProperty
set-content -Value $(ConvertTo-Json -InputObject $oState) -Path $jsonPath