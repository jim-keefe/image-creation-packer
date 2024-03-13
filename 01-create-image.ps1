param (
    $osversion = $(if ($env:SELECTOS) {$env:SELECTOS} else {"Win2022"}),
    $serverstandard = $(if ($env:SELECTSTANDARD -like "true"){$true} elseif($env:SELECTSTANDARD -like "false") { $false } else { $true }), # If false than Datacenter
    $servercore = $(if ($env:SELECTCORE -like "true"){$true} elseif($env:SELECTCORE -like "false") { $false } else { $true }) # If false includes GUI
)

$basepath = $env:BASE_HYPERV_PATH
$osflavor = "evaluation"

#================================================================
Write-Output "Determine the selection index (StandardCore = 1 Standard = 2 DataCenterCore = 3 DataCenter = 4)"
#================================================================

if ($serverstandard) { $osindex = 2 ; $osSelect = "ServerStandard" } else { $osindex = 4 ; $osSelect = "ServerDataCenter"}
if ($servercore) { $osindex-- ; $osSelect = "$($osSelect)Core"}
Write-Output "$osVersion$osSelect = $osIndex"

# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\pipeline-functions.ps1"

#================================================================
Write-Output "Update the autounattend.xml with the os index selection"
#================================================================

# consider this https://github.com/fpschultze/Update-UnattendXmlPassword/blob/master/Update-UnattendXmlPassword.ps1

$aNewxml = get-content "$basepath\Management\image-creation-packer\WinServer\files\template-autounattend.xml"

$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.osversion.search -replace $clist.osversion.replace -status $clist.osversion.status -uniquetag $clist.osversion.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.adminplain.search -replace $clist.adminplain.replace -status $clist.adminplain.status -uniquetag $clist.adminplain.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.adminpw.search -replace $clist.adminpw.replace -status $clist.adminpw.status -uniquetag $clist.adminpw.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.uaadminplain.search -replace $clist.uaadminplain.replace -status $clist.uaadminplain.status -uniquetag $clist.uaadminplain.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.uaadminpw.search -replace $clist.uaadminpw.replace -status $clist.uaadminpw.status -uniquetag $clist.uaadminpw.uniquetag

Set-Content -Value $aNewxml -Path "$basepath\Management\image-creation-packer\WinServer\files\autounattend.xml"

#================================================================
Write-Output "Update the sysprep-autounattend.xml with the os index selection"
#================================================================

$aNewxml = get-content "$basepath\Management\image-creation-packer\WinServer\files\template-sysprep-autounattend.xml"

$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.adminplain.search -replace $clist.adminplain.replace -status $clist.adminplain.status -uniquetag $clist.adminplain.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.adminpw.search -replace $clist.adminpw.replace -status $clist.adminpw.status -uniquetag $clist.adminpw.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.uaadminplain.search -replace $clist.uaadminplain.replace -status $clist.uaadminplain.status -uniquetag $clist.uaadminplain.uniquetag
$aNewxml = replace-betweenxmltags -xml $aNewxml -search $clist.uaadminpw.search -replace $clist.uaadminpw.replace -status $clist.uaadminpw.status -uniquetag $clist.uaadminpw.uniquetag

Set-Content -Value $aNewxml -Path "$basepath\Management\image-creation-packer\WinServer\files\sysprep-autounattend.xml"

#================================================================
Write-Output "Specify the ISO and MD5 based on $osVersion"
#================================================================

$isoRecs = get-content "$basepath\Management\isorecords.json" | ConvertFrom-Json
$isoName = $isoRecs.$osversion.isoname
$isomd5 = $isoRecs.$osversion.isomd5

#================================================================
Write-Output "Update the state JSON"
#================================================================

$isourl = "$basePath/ISOs/$isoName"

$oState = @{
    basepath = $basePath
    osversion = $osversion
    osflavor = $osflavor
    osyear = $osversion.Replace("Win","")
    isourl = $isourl
    isomd5 = $isomd5
    serverstandard = $serverstandard
    servercore = $servercore
    osSelect = $osSelect
}

if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if (Test-path -Path $jsonPath) { remove-item -Path $jsonPath -Force}
$oState | convertto-json | set-content -Path $jsonPath  

#================================================================
Write-Output "Execute the Packer Build"
#================================================================

$hclTemplatePath = "$basePath\Management\image-creation-packer\WinServer\template-WinServer.pkr.hcl"
$temphcl = get-content -Path $hclTemplatePath
foreach ($line in $temphcl){
    $line = $line.replace("9999999999","Win$($oState.osyear)$($oState.osselect)")
    $newhcl = "$newhcl`r`n$line"
}
$hclPath = "$basePath\Management\image-creation-packer\WinServer\WinServer.pkr.hcl"
set-content -path $hclPath -Value $newhcl
Set-Location (get-item $hclPath).Directory.FullName
cmd.exe /c packer init $hclPath # Install the windows update plugin for packer if it is not present
cmd.exe /c packer build -var "isourl=$isourl" -var "isomd5=$isomd5" -var "osyear=$($oState.osyear)" -var "osselect=$osSelect" $hclPath