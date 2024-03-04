source "hyperv-iso" "windows-server-2022" {
  iso_url      = "E:/Hyper-V/ISOs/SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum = "E7908933449613EDC97E1B11180429D1"

  floppy_files = [
    "files/autounattend.xml",
    "files/winrmconfig.ps1",
    "files/sysprep-autounattend.xml"
  ]

  boot_wait      = "2m"
  disk_size      = 61440
  guest_additions_mode = "disable"
  headless       = true
  output_directory = "E:/Hyper-V/Templates/win2022"
  shutdown_command = "C:\\Windows\\system32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /unattend:A:\\sysprep-autounattend.xml"
  shutdown_timeout = "5m"
  switch_name    = "External Switch Wireless"
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = "packer"
  winrm_insecure = true
  winrm_use_ssl = true
  winrm_timeout  = "10m"
}

build {
  sources = [
    "source.hyperv-iso.windows-server-2022",
  ]
  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
      "choco install -y python",
      "choco install -y git",
      "choco install -y sysinternals",
      "choco install -y bginfo"
    ]
  }
}