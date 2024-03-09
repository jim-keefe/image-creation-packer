param (
    $basepath = $env:BASE_HYPERV_PATH,
    $osversion = "Win2022",
    $serverstandard = $false,
    $servercore = $false,
    $isoname = "SERVER_EVAL_x64FRE_en-us.iso",
    $isomd5 = "e7908933449613edc97e1b11180429d1",
    $osflavor = "standard-eval"
)

function replace-betweenxmltags {
    param (
        $xml,
        $uniquetag,
        $status,
        $search,
        $replace
    )
    $out = ""
    foreach ($line in $xml){
        if ($status -lt 3){
            If ($line -like "*<$($uniquetag)>*"){ $status ++ }
            If ($line -like "*$search*"){
                $status ++
                $line = $line -replace $search,$replace 
            }
            If ($line -like "*</$uniquetag>*"){ $status ++ }
        }

        $out = "$out`r`n$line"
    }
    return $out

}

#================================================================
Write-Output "Determine the selection index (StandardCore = 1 Standard =2 DataCenterCore = 3 DataCenter = 4)"
#================================================================

if ($serverstandard) { $osindex = 2 ; $osSelect = "ServerStandard" } else { $osindex = 4 ; $osSelect = "ServerDataCenter"}
if ($servercore) { $osindex-- ; $osSelect = "$($osSelect)Core"}

$clist = @{
    description = "between the open and close of the unique xml tag find the search string and replace it"
    osversion = @{
        uniquetag = "InstallFrom"
        status = 0
        search = "<Value>1</Value>"
        replace = "<Value>$osindex</Value>"
    }
}

#================================================================
Write-Output "Update the autounattend.xml with the os index selection"
#================================================================

$tempxml = (get-content "$basepath\Management\image-creation-packer\WinServer\files\templateautounattend.xml").split("`r`n")
$newxml = replace-betweenxmltags -xml $tempxml -search $clist.osversion.search -replace $clist.osversion.replace -status $clist.osversion.status -uniquetag $clist.osversion.uniquetag
Set-Content -Value $newxml -Path "$basepath\Management\image-creation-packer\WinServer\files\autounattend.xml"

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

$hclTemplatePath = "$basePath\Management\image-creation-packer\WinServer\WinServer.pkr.hcl"
$temphcl = get-content -Path $hclTemplatePath
foreach ($line in $temphcl){
    $line = $line.replace("9999999999","Win$($oState.osyear)$($oState.osselect)")
    $newhcl = "$newhcl`r`n$line"
}
$hclPath = "$basePath\Management\image-creation-packer\WinServer\Win$($oState.osyear)$($oState.osselect).pkr.hcl"
set-content -path $hclPath -Value $newhcl
Set-Location (get-item $hclPath).Directory.FullName
cmd.exe /c packer build -var "isourl=$isourl" -var "isomd5=$isomd5" -var "osyear=$($oState.osyear)" -var "osselect=$osSelect" $hclPath

