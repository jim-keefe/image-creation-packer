#================================================================
Write-Output "Load state json"
#================================================================

$basepath = "E:\Hyper-V"
if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}
if ( Test-path -path $jsonPath ) { $oState = Get-Content -Path $jsonPath | ConvertFrom-Json }

#================================================================
Write-Output "Stop test vm $($oState.vmname) and Remove"
#================================================================

$tempvm = get-vm -Name $oState.vmname
Stop-VM -Name $oState.vmname -Force
Remove-VM -Name $oState.vmname -Force
Remove-Item -Path $tempvm.Path -Recurse -force

#================================================================
Write-Output "Move the new template to the Templates folder"
#================================================================

$atemptemplatepath = (get-item -Path $oState.vhdxtemplatepath).Directory.Fullname -split "\\"
for ($i = 0 ; $i -lt $atemptemplatepath.count -1; $i++){ $templatepath = "$templatepath\$($atemptemplatepath[$i])" }

if (Test-path -Path "$basepath\Templates\$(($oState.vhdxtemplatepath -split "\\")[-1])"){ remove-item -Path "$basepath\Templates\$(($oState.vhdxtemplatepath -split "\\")[-1])" -Force}
Move-Item $oState.vhdxtemplatepath -Destination "$basepath\Templates" -Force
Remove-Item -Path $templatepath.TrimStart("\") -Recurse -force