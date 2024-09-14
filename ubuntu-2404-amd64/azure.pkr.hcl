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
  output_directory  = "build/azure"
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
  name = "azure"

  sources = ["source.qemu.base-img"]

  provisioner "shell" {
    script          = "azure/provision/setup_sources_list.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/ubuntu/setup_kernel.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/debian/dist_upgrade.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/ubuntu/setup_grub_defaults.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script          = "../shared/azure/provision/ubuntu/setup_cloud_init.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "file" {
    sources     = ["../shared/azure/provision/linux/waagent.conf"]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script          = "../shared/azure/provision/ubuntu/setup_walinuxagent.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script          = "../shared/azure/provision/ubuntu/remove_netplan_configs.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script          = "../shared/azure/provision/linux/clean_walinuxagent.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script          = "../shared/azure/provision/linux/generalize.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
