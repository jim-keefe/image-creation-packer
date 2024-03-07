$basepath = "E:\Hyper-V"

if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = Get-Content -Path $jsonPath | ConvertFrom-Json }

$tempvm = get-vm -Name $oState.vmname

Write-Output "Stop vm $($oState.vmname) and Remove"
Stop-VM -Name $oState.vmname -Force
Remove-VM -Name $oState.vmname -Force
Remove-Item -Path $tempvm.Path -Recurse -force

Write-Output "Move the new template to the Templates folder"
$temptemplatepath = (get-item -Path $oState.vhdxtemplatepath).Directory.FullName
Move-Item $oState.vhdxtemplatepath -Destination "$($oState.$basepath)\Templates"
Remove-Item -Path $temptemplatepath -Recurse -force