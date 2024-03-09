param (
    $basepath = "E:\Hyper-V",
    $osversion = "win2022",
    $osflavor = "standard-eval",
    $isoname = "SERVER_EVAL_x64FRE_en-us.iso",
    $isomd5 = "E7908933449613EDC97E1B11180429D1",
    $serverstandard = $true,
    $servercore = $true
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
Set-Content -Value $newxml -Path "E:\Hyper-V\Management\image-creation-packer\WinServer\files\autounattend.xml"

#================================================================
Write-Output "Update the state JSON"
#================================================================

$isourl = "$basePath/ISOs/$isoName"

$oState = @{
    basepath = $basePath
    osversion = $osversion
    osflavor = $osflavor
    osyear = $osversion.Replace("win","")
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

$hclPath = "$basePath\Management\image-creation-packer\WinServer\WinServer.pkr.hcl"
Set-Location (get-item $hclPath).Directory.FullName
cmd.exe /c packer build -var "isourl=$isourl" -var "isomd5=$isomd5" -var "osyear=$($oState.osyear)" -var "osselect=$osSelect" $hclPath
