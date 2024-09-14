packer {
  required_version = "= 1.11.1"
  required_plugins {
    qemu = {
      version = "= 1.1.0"
      source = "github.com/hashicorp/qemu"
    }
  }
}
