# Working with Autounattend.xml files

## Summary
This doc is intended to be a brief overview of getting started with autounattended.xml files used to perform configuration during OS install.

## Requirements
* Windows System Image Manager found in the Windows ADK.

## Steps
1. Download and install the Windows ADK.
2. Right click on the Windows installation ISO and select Mount.
3. Create a work folder and give it a name (i.e. Win2022)
4. Copy the contents of the mounted ISO to the work folder.
5. Open the Windows System Image Manager tool (Start > Windows Kits).
6. Right click on Select Windows Image File or Catalog and click Select Windows Image.
7. Navigate to sources and select the install.wim.
8. Select the version of the OS and click OK (i.e. SERVERSTANDARD or SERVERSTANDARDCORE).
9. Under Answer File, right click and select New File.
9. Under Windows Image, review Components and Packages.
10. As a component is found for configuration, right click and add it to a Pass (1 through 7)
11. Select the component in the answer file and update values in the properties pane (Upper right).
12. You can also right click on Components and Packages nodes under the Answer File section and add commands, driver paths and packages to a variet of passess.
12. Once all the properties have been selected and configured, right click on the root of the answer file and select Close Answer File.
13. Save the answer file. Where you save it depends on your use case.

## Example
1. Mount the ISO and copy files to a work folder.
2. Using Windows SIM, open the sources/install.wim from the work folder.
3. Create a new answer file.
4. Add the Create Partition and Modify Partition components under wow64_Microsoft-Windows-Setup/DiskConfiguration/Disk to pass 1
5. Add the AutoLogon Component under wow64_Microsoft-Windows-Shell-Setup to pass 4
6. Right click on Components in the asnswer file to add a command to run in pass 4
7. Configure the values for the component and each parent node above (See examples in this repo... and others).
8. Save the answer file.

## Reference
* Take a look at this learn doc from Microsoft on working with unattend files. It has more deatils on configuration of components as well as next steps in delivering a configuration with an unattend file. [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11)
* This learn doc from Microsoft talks about the startegies for handling [secrets in unattended files](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview?view=windows-11#sensitive-data-in-answer-files)