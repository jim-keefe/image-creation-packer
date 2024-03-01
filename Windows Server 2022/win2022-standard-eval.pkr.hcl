source "hyperv-iso" "windows-server-2022" {
  iso_url      = "C:/Users/jimke/Downloads/SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum = "E7908933449613EDC97E1B11180429D1"

  floppy_files = [
    "files/autounattend.xml",
    "files/winrmconfig.ps1"
  ]

  boot_wait      = "2m"
  disk_size      = 61440
  guest_additions_mode = "disable"
  headless       = true
  output_directory = "e:/output-windows-server-2022"
  shutdown_command = "shutdown /s /t 10 /f"
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
      "choco install -y openssh",
      "New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22",
      "Start-Service sshd",
    ]
  }
}