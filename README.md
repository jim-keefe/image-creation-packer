# image-creation-packer

## Summary

This repository has proof of concept code for creating vm images on Hyper-V for Windows Server 2022. See the sample output below for successful results.

## Requirements

* The Hyper-V service with Windows 10/11.
* Packer from Hashicorp installed on Windows.
* The Hyper-V extension for Packer.
* A URL to the Windows Server 2022 ISO (a UNC path works too)
* DHCP is required to get an IP and TCP connectivity.
  * Alternately a static IP could be used by configuring the NIC with a script in the autounattend.xml.
* The Packer host needs WinRM connectivity on port 5986 to reach the target VM for the imaging process.

## Usage

1. Edit variables in the file as needed for the Hyper-V environment.
2. Confirm that the password specified for the Administrator account in the files/autounattend.xml matches the winrm_password specified in the Win2022-standard-eval.pkr.hcl file.
3. Open a CMD shell with RunAs Administrator.
4. Navigate to the directory that contains the Win2022-standard-eval.pkr.hcl file.
5. Execute the following packer command...
```
packer build win2022-standard-eval.pkr.hcl
```

## Sample Output

![alt text](<screenshots/Screenshot 2024-02-29 211147.png>)
![alt text](<screenshots/Screenshot 2024-02-29 211830.png>)

## Future Enhancements

* Add pipeline functionality for build and test (maybe with Jenkins).
* Set up a Windows Server 2019 image.
* Add firewall rules on the client system running Packer.
* Add some naming conventions.
