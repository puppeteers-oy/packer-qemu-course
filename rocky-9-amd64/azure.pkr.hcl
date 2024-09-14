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
  output_directory  = "build/azure"
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
  name = "azure"

  sources = ["source.qemu.base-img"]

  provisioner "shell" {
    script            = "../shared/redhat/setup_networkmanager.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/setup_sshd.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "file" {
    sources     = ["../shared/azure/provision/linux/waagent.conf"]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/setup_walinuxagent.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/setup_cloud_init.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/remove_swapfile.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/setup_grub.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

 provisioner "shell" {
    script            = "redhat/azure/setup_grub.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    script            = "../shared/azure/provision/redhat/setup_dracut.sh"
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
    script            = "../shared/azure/provision/redhat/deprovision.sh"
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
