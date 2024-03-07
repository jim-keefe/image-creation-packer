# image-creation-packer

## Summary

This repository has proof of concept code for creating vm images on Hyper-V for Windows Server 2022 using Hashicorp Packer. As well a Jenkinsfile is included with a CI/CD pipeline for image creation. The pipeline creates the image, provisions a server from the image, tests the provisioned server for configuration and then deploys the template for later consumption. During the pipeline run, a json file is used to store vars accross stages. See the sample output below for successful results.

## Requirements

* The Hyper-V service with Windows 10/11.
* Packer from Hashicorp installed on Windows.
* The Hyper-V extension for Packer.
* A URL to the Windows Server 2022 ISO (a UNC path works too)
* DHCP is required to get an IP and TCP connectivity.
  * Alternately a static IP could be used by configuring the NIC with a script in the autounattend.xml.
* The Packer host needs WinRM connectivity on port 5986 to reach the target VM for the imaging process.
* Jenkins installed on Windows.
* The service account for Jenkins needs to be added to the Hyper-V administrators group.
* A minumum folder structure that starts at $basePath defined in the scripts... i.e.
  * e:\Hyper-V\ISOs
  * e:\Hyper-V\Templates
  * e:\Hyper-V\VirtualMachines
  * e:\Hyper-V\Management
  * e:\Hyper-V\Management\image-creation-packer <<<- This repo
  * e:\Hyper-V\Management\jenkinsJSON

## Usage
### Packer
1. Edit variables in the file as needed for the Hyper-V environment.
2. Confirm that the password specified for the Administrator account in the files/autounattend.xml matches the winrm_password specified in the Win2022-standard-eval.pkr.hcl file.
3. Open a CMD shell with RunAs Administrator.
4. Navigate to the directory that contains the Win2022-standard-eval.pkr.hcl file.
5. Execute the following packer command...
```
packer build win2022-standard-eval.pkr.hcl
```
### Jenkins
1. Create a Jenkins Pipeline.
2. Add the contents of the jenkinsfile to the script text area.
  * Alternately, use SCM to clone the repo.
3. Edit paths in the groovy script as needed.

## Sample Output
### Packer
![alt text](<screenshots/Screenshot 2024-02-29 211147.png>)
![alt text](<screenshots/Screenshot 2024-02-29 211830.png>)

## Future Enhancements

* Add pipeline functionality for build and test.
  * Update: A working pipeline has been created with Jenkins.
* Further Parameterize the code to easily adapt to other OS versions and flavors.
* Add security controls (jenkins creds or a vault)
* Add Linux image creation.
* Stand up a Linux Jenkins agent.
* Add firewall rules on the client system running Packer.
* Add a prereqs script to create a folder structure and check the stack.
* streamline the code (i.e. json update functions).
* Add security patching to image creation.
* Schedule pipeline runs (or trigger them).
