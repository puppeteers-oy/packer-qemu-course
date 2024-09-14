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
  vm_name              = "ubuntu-2404-amd64.raw"
  iso_url              = "https://www.releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
  iso_checksum         = "8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
  memory               = 1500
  disk_image           = false
  output_directory     = "build/os-base"
  accelerator          = "kvm"
  disk_size            = "12000M"
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
  name    = "iso"
  sources = ["source.qemu.iso"]
}
