# A JSON file is currently used to source secrets

$secrets = @{
    localadmin = @{
        name = "Administrator"
        password = "password"
    }
    sysadmin = @{
        name = "psmanage"
        password = "password"
    }
    newlocaladmin = @{
        name = "tempacct"
        password = "password"
    }
}

$jsonOut = ConvertTo-Json -InputObject $secrets -Depth 20
set-content -path E:\Hyper-V\Management\secrets.json -Value $jsonOut