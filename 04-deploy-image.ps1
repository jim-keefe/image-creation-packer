# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\pipeline-functions.ps1"

#================================================================
Write-Output "Load state json"
#================================================================

$basepath = $env:BASE_HYPERV_PATH
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
$templatename = (get-item -Path $oState.vhdxtemplatepath).Name
for ($i = 0 ; $i -lt $atemptemplatepath.count -1; $i++){ $templatepath = "$templatepath\$($atemptemplatepath[$i])" }

if (Test-path -Path "$basepath\Templates\$(($oState.vhdxtemplatepath -split "\\")[-1])"){ remove-item -Path "$basepath\Templates\$(($oState.vhdxtemplatepath -split "\\")[-1])" -Force}
Move-Item $oState.vhdxtemplatepath -Destination "$basepath\Templates" -Force
Remove-Item -Path $templatepath.TrimStart("\") -Recurse -force
if (Test-Path "$basepath\Templates\$($templatename.TrimStart("packer-"))"){ remove-item "$basepath\Templates\$($templatename.TrimStart("packer-"))" -force}
Rename-Item "$basepath\Templates\$templatename" -NewName "$($templatename.TrimStart("packer-"))"