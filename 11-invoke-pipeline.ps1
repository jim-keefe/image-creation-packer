#================================================================
Write-Output "Set the number of minutes between pipeline jobs"
#================================================================

$miutesbetweenjobs = 15
write-output "Minutes Between Jobs: $minutesbetweenjobs"

#================================================================
Write-Output "Define the OS and Variations"
#================================================================

$OStable = @{
    2019 = @{
        standard = @{
            os = "Win2019"
            standard = "true"
            core = "false"
        }
        standardcore = @{
            os = "Win2019"
            standard = "true"
            core = "true"
        }
        datacenter = @{
            os = "Win2019"
            standard = "false"
            core = "false"
        }
        datacentercore = @{
            os = "Win2019"
            standard = "false"
            core = "true"
        }
    }
    2022 = @{
        standard = @{
            os = "Win2022"
            standard = "true"
            core = "false"
        }
        standardcore = @{
            os = "Win2022"
            standard = "true"
            core = "true"
        }
        datacenter = @{
            os = "Win2022"
            standard = "false"
            core = "false"
        }
        datacentercore = @{
            os = "Win2022"
            standard = "false"
            core = "true"
        }
    }
}

$result = @()

#================================================================
Write-Output "Iterate through the OS versions and variants to invoke pipeline jobs"
#================================================================

foreach ($year in $OStable.keys){
    foreach ($variant in $OStable.$year.keys) {

        $os = $OStable.$year.$variant.os
        $standard = $OStable.$year.$variant.standard
        $core = $OStable.$year.$variant.core

        #================================================================
        Write-Output "Send a web request for os: $os$variant standard: $standard core: $core"
        #================================================================

        $jURL = "http://localhost:8080/job/Packer%20Image%20Pipeline/buildWithParameters?token=superhugetiger&SELECTOS=$os&SELECTSTANDARD=$standard&SELECTCORE=$core"
        $tempresult = Invoke-WebRequest $jURL
        write-output $tempresult
        $result += $tempresult

        Start-Sleep -Seconds ($miutesbetweenjobs*60)
        
    }
}

write-output $result
# Out-GridView $result