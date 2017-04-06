##############################################################################
# IBM Cloud Provider
# Provider details available at
# http://ibmcloudterraformdocs.chriskelner.com/docs/providers/ibmcloud/index.html
##############################################################################
# See the README for details on ways to supply these values
provider "ibmcloud" {
  ibmid                    = "${var.ibmid}"
  ibmid_password           = "${var.ibmidpw}"
  softlayer_account_number = "${var.slaccountnum}"
}

##############################################################################
# IBM SSH Key: For connecting to VMs
# http://ibmcloudterraformdocs.chriskelner.com/docs/providers/ibmcloud/r/infra_ssh_key.html
##############################################################################
resource "ibmcloud_infra_ssh_key" "ssh_key" {
  label = "interconnect-2017"
  notes = "interconnect-2017"
  # Public key, so this is completely safe
  public_key = "${var.public_key}"
}

##############################################################################
# IBM Virtual Guests -- Web Resource Definition
# http://ibmcloudterraformdocs.chriskelner.com/docs/providers/ibmcloud/r/infra_virtual_guest.html
##############################################################################
resource "ibmcloud_infra_virtual_guest" "web_node" {
  # number of nodes to create, will iterate over this resource
  count                = "${var.node_count}"
  # demo hostname and domain
  hostname             = "interconnect2017-demo-web-node-${count.index+1}"
  domain               = "interconnect2017demo.com"
  # the operating system to use for the VM
  os_reference_code    = "${var.web_operating_system}"
  # the datacenter to deploy the VM to
  datacenter           = "${var.datacenter}"
  private_network_only = false
  cores                = "${var.vm_cores}"
  memory               = "${var.vm_memory}"
  local_disk           = true
  ssh_key_ids = [
    "${ibmcloud_infra_ssh_key.ssh_key.id}"
  ]
  # Installs nginx web server on our VM via SSH
  provisioner "remote-exec" {
    inline = [
      "apt-get update -y",
       # Install nginx
      "apt-get install --yes --force-yes nginx",
      # Overwrite default nginx welcome page w/ mac address of VM NIC
      "echo \"<h1>I am $(cat /sys/class/net/eth0/address)</h1>\" > \"/var/www/html/index.nginx-debian.html\""
    ]
  }
  # applys tags to the VM
  tags = "${var.vm_tags}"
}

##############################################################################
# Outputs: printed at the end of terraform apply
##############################################################################
output "node_id" {
    value = ["${ibmcloud_infra_virtual_guest.web_node.id}"]
}
output "node_ip_address" {
    value = ["${ibmcloud_infra_virtual_guest.web_node.ipv4_address}"]
}

##############################################################################
# Variables
##############################################################################
# Required for the IBM Cloud provider
variable ibmid {
  type = "string"
  description = "Your IBM-ID."
}
# Required for the IBM Cloud provider
variable ibmidpw {
  type = "string"
  description = "The password for your IBM-ID."
}
# Required to target the correct SL account
variable slaccountnum {
  type = "string"
  description = "Your Softlayer account number."
}
# The datacenter to deploy to
variable datacenter {
  default = "dal06"
}
# The SSH Key to use on the Nginx virtual machines
# Defined in terraform.tfvars
variable public_key {
  description = "Your public SSH key"
}
# The number of web nodes to deploy; You can adjust this number to create more
# virtual machines in the IBM Cloud; adjusting this number also updates the
# loadbalancer with the new node
variable node_count {
  default = 1
}
# The target operating system for the web nodes
variable web_operating_system {
  default = "UBUNTU_LATEST"
}
# The port that web and the loadbalancer will serve traffic on
variable port {
  default = "80"
}
# The number of cores each web virtual guest will recieve
variable vm_cores {
  default = 1
}
# The amount of memory each web virtual guest will recieve
variable vm_memory {
  default = 1024
}
# Tags which will be applied to the web VMs
variable vm_tags {
  default = [
    "nginx",
    "webserver",
    "schematicsdemo"
  ]
}
