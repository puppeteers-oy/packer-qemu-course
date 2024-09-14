source "qemu" "iso" {
  vm_name              = "ubuntu-2004-amd64-iso.qcow2"
  iso_url              = "https://www.releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
  iso_checksum         = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
  memory               = 1280
  disk_image           = false
  output_directory     = "build/iso"
  accelerator          = "kvm"
  disk_size            = "12000M"
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  boot_command         = [
    # Make the language selector appear...
    " <up><wait>",
    # ...then get rid of it
    " <up><wait><esc><wait>",

    # Go to the other installation options menu and leave it
    "<f6><wait><esc><wait>",

    # Remove the kernel command-line that already exists
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",

    # Add kernel command-line and start install
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
    "<enter>"
    ]
  http_directory       = "http"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  # These are required or Packer will panic, even if no provisioners are not
  # configured
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
}

# Run provisioning scripts on top of the image created above
source "qemu" "img" {
  vm_name           = "ubuntu-2004-amd64-img.qcow2"
  iso_url           = "build/iso/ubuntu-2004-amd64-iso.qcow2"
  iso_checksum      = "none"
  disk_image        = true
  memory            = 1280
  output_directory  = "build/img"
  accelerator       = "kvm"
  disk_size         = "12000M"
  disk_interface    = "virtio"
  format            = "qcow2"
  net_device        = "virtio-net"
  boot_wait         = "3s"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username      = "packer"
  ssh_password      = "packer"
  ssh_timeout       = "60m"
}

build {
  name = "iso"

  sources = ["source.qemu.iso"]
}

build {
  name = "img"

  sources = ["source.qemu.img"]

  provisioner "file" {
    sources     = [
                    "provision/test.sh"
                  ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script          = "provision/test.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
