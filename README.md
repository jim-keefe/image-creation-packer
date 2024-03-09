# image-creation-packer

## Summary

This repository has proof of concept code for automated creation of Windows Server VM images on Hyper-V using Hashicorp Packer and Jenkins in a CI/CD pipeline. The pipeline creates the image, provisions a test server from the image, tests the provisioned server for configuration and then deploys the exported image template for later consumption. See the sample output below for successful results.

## Features
* **Local Admin credentials are vaulted inside of Jenkins.** The creds are made available in the session for the current job through environment variables. Where the creds are used in Packer, they have been tagged as sensitive. In Powershell, the creds are encypted using secure strings.
* **The process is parametized.** About 5 beginning parameter values can be used to start the process.
* **A JSON file is used to record values** during the various stages of the pipeline. In this way discovered values such as the virtual hard disk path can be used in later pipeline stages. The remaining JSON also serves as a record.
* **The automation uses a templateautounattend.xml to dynamically generate the autounattend file** for the selected OS (i.e. Windows Server StandardCore, Standard, DatacenterCore or Datacenter)
* **The automation uses a single Packer HCL file** as a template. The automation dynamically generates HCL files based on the selected OS parameters.

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
* A minumum folder structure that starts at base path... i.e.
  * e:\Hyper-V\ISOs
  * e:\Hyper-V\Templates
  * e:\Hyper-V\VirtualMachines
  * e:\Hyper-V\Management
  * e:\Hyper-V\Management\image-creation-packer <<<- This repo
  * e:\Hyper-V\Management\jenkinsJSON

## High Level Usage
### Packer
1. Edit variables in the HCL file as needed for the Hyper-V environment.
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
5. Add the localadmin creds to a credentials record in Jenkins.
3. Edit paths in the groovy script as needed.
5. Edit the environment variables in the groovy script.
6. Execute Build Now.

## Sample Output
### Jenkins
![alt text](<screenshots/Screenshot 2024-03-07 114224.png>)
### Packer
![alt text](<screenshots/Screenshot 2024-02-29 211147.png>)
![alt text](<screenshots/Screenshot 2024-02-29 211830.png>)

## Future Enhancements

* Add pipeline functionality for build and test.
  * Update: A working pipeline has been created with Jenkins.
* Further Parameterize the code to easily adapt to other OS versions and flavors.
  * Update: Better parameterization has been added (3/9/2024).
* Add security controls (jenkins creds or a vault)
  * Jenkins creds are now used and plaintext passwords removed (3/9/2024).
* **Add Linux image creation.**
* **Add Terraform to the automation stack**
* Stand up a Linux Jenkins agent.
* Add firewall rules on the client system running Packer.
* Add a prereqs script to create a folder structure and check the stack.
* streamline the code (i.e. json update functions).
* Add security patching to image creation.
* Schedule pipeline runs (or trigger them).
* Add Ansible and possibly AWX to the automation stack.
* Add a WSUS server to manage Windows security patches.
