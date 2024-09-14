packer {
  required_version = "= 1.11.1"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}

# Run provisioning scripts on top of the image created above
source "qemu" "base-img" {
  vm_name           = "rocky-9-amd64.raw"
  iso_url           = "build/os-base/rocky-9-amd64.raw"
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
  cpu_model         = "host"
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
    script            = "../shared/redhat/setup_networkmanager.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "redhat/aws/setup_grub.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "redhat/fix_grub_root_disk.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "redhat/fix_fstab.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/aws/provision/redhat/deprovision.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
