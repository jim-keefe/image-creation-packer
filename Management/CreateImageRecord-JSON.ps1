# A JSON file is currently used to source secrets

$isorecs = @{
    Win2019 = @{
        isoname = "17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
        isomd5 = "C2592569DF937AFF1C21DAFD3D4E9B40"
    }
    Win2022 = @{
        isoname = "SERVER_EVAL_x64FRE_en-us.iso"
        isomd5 = "E7908933449613EDC97E1B11180429D1"
    }
}

$jsonOut = ConvertTo-Json -InputObject $isorecs -Depth 20
set-content -path E:\Hyper-V\Management\isorecords.json -Value $jsonOut