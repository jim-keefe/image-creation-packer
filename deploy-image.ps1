$basepath = "E:\Hyper-V"

if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if ( Test-path -path $jsonPath ) { $oState = Get-Content -Path $jsonPath | ConvertFrom-Json }

$tempvm = get-vm -Name $oState.vmname

Stop-VM -Name $oState.vmname -Force
Remove-VM -Name $oState.vmname -Force
Remove-Item -Path $tempvm.Path -Recurse -force

Move-Item $oState.vhdxtemplatepath -Destination "$($oState.$basepath)\Templates\$($oState.$osversion)-$($oState.$osflavor).hcl"
$temptemplatepath = (get-item -Path $oState.vhdxtemplatepath).Directory.FullName
Remove-Item -Path $temptemplatepath -Recurse -force