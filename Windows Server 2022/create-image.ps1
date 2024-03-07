param (
    $basepath = "E:\Hyper-V",
    $osversion = "win2022",
    $osflavor = "standard-eval"
)

if ($env:BUILD_TAG){
    $jsonPath = "$basepath\Management\pipelineJSON\$($env:BUILD_TAG).json"
} else {
    $jsonPath = "$basepath\Management\pipelineJSON\$OSversion$("-")$OSflavor.json"   
}

if (Test-path -Path $jsonPath) { remove-item -Path $jsonPath -Force}

$oState = @{
    basepath = $basePath
    osversion = $osversion
    osflavor = $osflavor
}
$oState | convertto-json | set-content -Path $jsonPath  


$hclPath = "$basePath\Management\image-creation-packer\Windows Server 2022\$OSversion$("-")$OSflavor.pkr.hcl"

Set-Location (get-item $hclPath).Directory.FullName
cmd.exe /c packer build $hclPath

