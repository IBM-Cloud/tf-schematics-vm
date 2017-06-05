##############################################################################
# Configures the IBM Cloud provider
# https://ibm-bluemix.github.io/tf-ibm-docs/
##############################################################################
provider "ibmcloud" {
  bluemix_api_key    = "${var.ibmcloud_bx_api_key}"
  softlayer_username = "${var.ibmcloud_sl_username}"
  softlayer_api_key  = "${var.ibmcloud_sl_api_key}"
}
#############################################################################
# Require terraform 0.9.3 or greater to run this template
# https://www.terraform.io/docs/configuration/terraform.html
#############################################################################
terraform {
  required_version = ">= 0.9.3"
}
#############################################################################
# SSH Key
# Create an SSH key using user supplied public key material for connecting
# to the virtual machines created
# https://ibm-bluemix.github.io/tf-ibm-docs/r/infra_ssh_key.html
#############################################################################
resource "ibmcloud_infra_ssh_key" "ssh_key" {
  label      = "${var.key_label}"
  notes      = "${var.key_note}"
  public_key = "${var.public_key}"
}
##############################################################################
# IBM Virtual Guests
# https://ibm-bluemix.github.io/tf-ibm-docs/r/infra_virtual_guest.html
##############################################################################
resource "ibmcloud_infra_virtual_guest" "node" {
  # To manually scale out horizonatally this value can be adjusted
  # Will create this number of nodes using these parameters
  count                = "${var.node_count}"
  hostname             = "${var.node_domain}-${count.index+1}"
  domain               = "${var.node_domain}"
  os_reference_code    = "${var.node_operating_system}"
  datacenter           = "${var.datacenter}"
  private_network_only = false
  cores                = "${var.node_cores}"
  memory               = "${var.node_memory}"
  local_disk           = true
  ssh_key_ids = [
    "${ibmcloud_infra_ssh_key.ssh_key.id}"
  ]
  post_install_script_uri = "https://raw.githubusercontent.com/IBM-Bluemix/tf-schematics-vm/master/post-install.sh"
  tags = "${var.node_tags}"
}

##############################################################################
# Outputs: printed at the end of terraform apply
##############################################################################
output "node_ids" {
    value = ["${ibmcloud_infra_virtual_guest.node.*.id}"]
}
output "node_ip_addresses" {
    value = ["${ibmcloud_infra_virtual_guest.node.*.ipv4_address}"]
}

##############################################################################
# Variables
##############################################################################
# Required for the IBM Cloud provider for Bluemix resources
variable "ibmcloud_bx_api_key" {
  type = "string"
  description = "Your Bluemix API Key."
}
# Required for the IBM Cloud provider for Softlayer resources
variable "ibmcloud_sl_username" {
  type = "string"
  description = "Your Softlayer username."
}
# Required for the IBM Cloud provider for Softlayer resources
variable "ibmcloud_sl_api_key" {
  type = "string"
  description = "Your Softlayer API key."
}
variable "datacenter" {
  type = "string"
  default = "dal06"
  description = "The target datacenter to deploy virtual machines to."
}
# The SSH Key public key material to use for the virtual machines
variable "public_key" {
  type = "string"
  description = "Your public SSH key material."
}
variable "key_label" {
  type = "string"
  default = "schematics-vm-demo"
  description = "A label (name) for your SSH key."
}
variable "key_note" {
  type = "string"
  default = "schematics-vm-demo"
  description = "A note (description) for your SSH key."
}
variable "node_count" {
  default = 1
  description = "The number of virtual machines to create."
}
variable "node_operating_system" {
  default = "UBUNTU_LATEST"
  description = "The target operating system for the virtual machines."
}
variable "node_domain" {
  default = "schematicsdemo"
  description = "The domain and hostname to apply to the virtual machines."
}
variable "node_cores" {
  default = 1
  description = "The number of cores each web virtual machine will recieve."
}
variable "node_memory" {
  default = 1024
  description = "The amount of memory each web virtual machine will recieve."
}
variable "node_tags" {
  default = [
    "nginx",
    "schematicsdemo"
  ]
  description = "Tags which will be applied to the web VMs."
}
