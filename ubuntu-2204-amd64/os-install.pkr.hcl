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
  vm_name              = "ubuntu-2204-amd64.raw"
  iso_url              = "https://www.releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  iso_checksum         = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  memory               = 1500
  disk_image           = false
  output_directory     = "build/os-base"
  accelerator          = "kvm"
  disk_size            = "8000M"
  disk_interface       = "virtio"
  format               = "raw"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  boot_command         = [
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=\"nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/\" ",
    "<f10>"
    ]
  http_directory       = "http"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
}

build {
  name = "iso"

  sources = ["source.qemu.iso"]
}
