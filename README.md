# Single VM Template for IBM Cloud Schematics
A simple Terraform configuration for a single virtual machine running a web
server (nginx) on IBM Cloud. By default this template will create an SSH key
and a single virtual machines. Using the `node_count` variable the number of
virtual machines can be adjusted.

# Usage
This is not a module, it is a terraform configuration that should be cloned for
use and modified as necessary.

Variables can be defined or overwritten using `terraform.tfvars` or defined
within the schematics service. This repo includes a `terraform.tfvars` that
defined a value for the variable `public_key` -- this value should be replaced
with your own public key material.

[To run this project with IBM Cloud Schematics please click here and follow the
getting started
guide.](https://console.ng.bluemix.net/docs/services/schematics/index.html#gettingstarted)
