packer {
  required_version = "= 1.11.1"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "iso" {
  vm_name              = "rocky-9-amd64.raw"
  iso_url              = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso"
  iso_checksum         = "eef8d26018f4fcc0dc101c468f65cbf588f2184900c556f243802e9698e56729"
  memory               = 1500
  disk_image           = false
  output_directory     = "build/os-base"
  accelerator          = "kvm"
  disk_size            = "12000M"
  disk_interface       = "virtio"
  format               = "raw"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  boot_command         = ["<up>",
                          "<tab><wait>",
                          " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/ks.cfg",
                          "<enter>"
    ]
  http_directory       = "http"
  # Required on RHEL 9 or there will be a kernel panic on boot. Search "RHEL9" in here for details:
  #
  # https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu
  #
  cpu_model            = "host"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  # These are required or Packer will panic, even if no provisioners are not
  # configured
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
}

build {
  name = "iso"

  sources = ["source.qemu.iso"]
}
