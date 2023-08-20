#!/bin/bash

# update packages
echo "updating packages"
sudo apt-get update -y

# enable ssm-sgent
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service

# install nfs tool
echo "installing efs mount helper"
cd /
sudo apt-get -y install git binutils
sudo git clone https://github.com/aws/efs-utils
cd /efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

echo "creating jenkins directory"
cd /var/lib
sudo mkdir jenkins

# mount efs on /var/lib/jenkins path
echo "mounting efs"
sudo mount -t efs -o tls ${efs_id}:/ /var/lib/jenkins
echo "${efs_id}:/ /var/lib/jenkins efs defaults,_netdev  0 0" >> /etc/fstab
echo "efs mounted"

# install jenkins
# echo "installing jenkins"
# sudo apt install openjdk-11-jre -y
# curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install jenkins -y
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

sudo apt update -y
sudo apt install default-jre -y
sudo apt install default-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
