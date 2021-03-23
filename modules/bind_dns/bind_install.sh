#!/bin/sh
sudo apt-get update 
sudo apt-get install -y bind9 bind9utils bind9-doc 
cd /etc/bind 
sudo rm named.conf.options 
sudo wget https://raw.githubusercontent.com/GinSiuCheng/private-aks-deployment/master/modules/bind_dns/named.conf.options
sudo named-checkconf
sudo systemctl restart bind9
sudo ufw allow bind9