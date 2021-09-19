#!/bin/bash

###
### Shell environment
###

apt update
apt install -y zsh
usermod --shell /bin/zsh ubuntu

#
# github keys
#
ubuntu_home=/home/ubuntu

touch $ubuntu_home/.ssh/id_rsa
touch $ubuntu_home/.ssh/id_rsa.pub
chmod 600 $ubuntu_home/.ssh/id_rsa*
chown ubuntu:ubuntu $ubuntu_home/.ssh/id_rsa*
aws ssm get-parameter --region us-east-2 --name "/dev-env/ssh/default-private-key" --query Parameter.Value --with-decryption --out text > $ubuntu_home/.ssh/id_rsa
aws ssm get-parameter --region us-east-2 --name "/dev-env/ssh/default-public-key"  --query Parameter.Value --with-decryption --out text > $ubuntu_home/.ssh/id_rsa.pub

#
# dot files
#
su ubuntu -lc "git clone https://github.com/frayer/terraform-linux-dev.git /tmp/terraform-linux-dev"
su ubuntu -lc "find /tmp/terraform-linux-dev/dot-files -type f -exec mv {} \$HOME/ \\;"
rm -fr /tmp/terraform-linux-dev

su ubuntu -lc 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
su ubuntu -lc "mv .zshrc.pre-oh-my-zsh .zshrc"

#
# Volume setup
#
mkfs -t xfs /dev/nvme1n1
mkdir /mnt/workspace
mount /dev/nvme1n1 /mnt/workspace
chown ubuntu:ubuntu /mnt/workspace
su ubuntu -lc 'ln -sf /mnt/workspace /home/ubuntu/workspace'
