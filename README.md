# image-creation-packer

## Summary

This is a CI/CD pipeline for creating OS images using Hashicorp Packer and Jenkins. The pipeline follows the basic build, test and deploy pattern. The Virtual Machine host in this case is provided by Hyper-V. 

At this time Windows Server 2019 and Windows Server 2022 are defined. With all of the variations for each OS (Standard, Datacenter AND... Core OR GUI of each), this result is a pipeline that produces 8 Windows image variations. The [sample output](#abcd) from Jenkins illustrates the variations. 

## Features
* The process is parametized at all levels. Jenkins takes input to start a job, passes value to the Powershell helpers, which then pass values to Packer and Hyper-V.
* A simple web request can be used with an access token to initiate build jobs with parameters. [This script](11-invoke-pipeline.ps1) invokes the 8 variations mentioned above. Where [March 12, 2024](#abcd) is the second Tuesday, this script can be used to update all Windows images.
* Credentials used during the process are vaulted in Jenkins. There are no clear text instances of passwords.
* The process dynamically creates the packer HCL build file and the autounattend.xml from template files. This limits the number of files that are manually maintained.
* JSON files are used to record values during the process. This is helpful for monitoring and troubleshooting.

## Requirements

* The Hyper-V service with Windows 10/11.
* Packer from Hashicorp installed on Windows.
* The [Hyper-V extension](https://developer.hashicorp.com/packer/integrations/hashicorp/hyperv) for Packer.
* The [Windows-Update plugin](https://github.com/rgl/packer-plugin-windows-update) for packer.
* ISOs in the ISOs folder defined in JSON. [This script](Management/CreateImageRecord-JSON.ps1) can create the JSON.
* DHCP is required to get an IP and TCP connectivity.
  * Alternately a static IP could be used by configuring the NIC with a script in the autounattend.xml.
* The Packer host needs WinRM connectivity on port 5986 to reach the target VM for the imaging process.
* Jenkins installed on Windows.
* The service account for Jenkins needs to be added to the Hyper-V administrators group.
* A minumum folder structure that starts at the base path... i.e.
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
6. Execute Build With Parameters.
7. Fill in the parameter values in the form...
* ![alt text](<screenshots/Screenshot 2024-03-12 223702.png>)

## Jenkins Sample Output<a name="abcd">-</a>

![alt text](<screenshots/Screenshot 2024-03-12 212633.png>)

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
