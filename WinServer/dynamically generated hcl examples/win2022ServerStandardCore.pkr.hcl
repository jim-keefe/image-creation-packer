
variable "isourl" {
  type = string
  default = "strawberry"
}

variable "isomd5" {
  type = string
  default = "strawberry"
}

variable "osyear" {
  type = string
  default = "2022"
}

variable "osselect" {
  type = string
  default = "check"
}

variable "lapw" {
  type = string
  sensitive = true
  default = "${env("BUILD_LOCAL_ADMIN_PSW")}"
}

source "hyperv-iso" "Win2022ServerStandardCore" {
  iso_url      = "${var.isourl}"
  iso_checksum = "${var.isomd5}"

  floppy_files = [
    "files/autounattend.xml",
    "files/winrmconfig.ps1",
    "files/sysprep-autounattend.xml"
  ]

  boot_wait      = "2m"
  disk_size      = 35000
  guest_additions_mode = "disable"
  headless       = true
  output_directory = "E:/Hyper-V/Templates/Win${var.osyear}${var.osselect}"
  shutdown_command = "C:\\Windows\\system32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /unattend:A:\\sysprep-autounattend.xml"
  shutdown_timeout = "5m"
  switch_name    = "External Switch Wireless"
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = "${var.lapw}"
  winrm_insecure = true
  winrm_use_ssl = true
  winrm_timeout  = "10m"
}

build {
  sources = [
    "source.hyperv-iso.Win2022ServerStandardCore",
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
