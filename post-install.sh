# /bin/bash
# An example post-install bash script
# This script would be configured to install all necessary software for the node
# https://sldn.softlayer.com/blog/jarteche/Getting-Started-User-Data-and-Post-Provisioning-Scripts

# update packages
apt-get update -y

# install software - as an example, nginx
apt-get install --yes --force-yes nginx

# Overwrite default nginx welcome page w/ mac address of VM NIC
echo "<h1>I am $(cat /sys/class/net/eth0/address)</h1>" > "/var/www/html/index.nginx-debian.html"

# additional configuration and installation
# ...
