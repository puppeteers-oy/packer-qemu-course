packer {
  required_version = "= 1.11.1"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}
source "qemu" "base-img" {
  vm_name           = "ubuntu-2404-amd64.raw"
  iso_url           = "build/os-base/ubuntu-2404-amd64.raw"
  iso_checksum      = "none"
  disk_image        = true
  memory            = 1500
  output_directory  = "build/aws"
  accelerator       = "kvm"
  disk_size         = "12000M"
  disk_interface    = "virtio"
  format            = "raw"
  net_device        = "virtio-net"
  boot_wait         = "3s"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username      = "packer"
  ssh_password      = "packer"
  ssh_timeout       = "60m"
  headless          = true
}

build {
  name = "aws"

  sources = ["source.qemu.base-img"]

  provisioner "shell" {
    script            = "../shared/debian/dist_upgrade.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
