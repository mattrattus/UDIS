#!/usr/bin/env bash

#UDIS
#v1.0.1
#by mattrattus
#https://mattrattus.github.io

echo -e "\033[36m<<<<<===== Change the root password =====>>>>>\033[0m"
passwd

echo -e "\033[36m<<<<<===== timezone config =====>>>>>\033[0m"
timedatectl set-timezone Europe/Warsaw

echo -e "\033[36m<<<<<===== Update =====>>>>>\033[0m"
apt update
apt -y upgrade

echo -e "\033[36m<<<<<===== Installing additional software =====>>>>>\033[0m"
apt -y install curl ufw fail2ban rkhunter unhide vim git zsh unzip htop tar rsync locales

echo -e "\033[36m<<<<<===== Locale config =====>>>>>\033[0m"
locale-gen en_US.UTF-8
locale-gen pl_PL.UTF-8

echo "LANG=en_US.UTF-8
LC_MESSAGES=C
LC_ADDRESS=pl_PL.UTF-8
LC_IDENTIFICATION=pl_PL.UTF-8
LC_MEASUREMENT=pl_PL.UTF-8
LC_MONETARY=pl_PL.UTF-8
LC_NAME=pl_PL.UTF-8
LC_NUMERIC=pl_PL.UTF-8
LC_PAPER=pl_PL.UTF-8
LC_TELEPHONE=pl_PL.UTF-8
LC_TIME=pl_PL.UTF-8" > /etc/locale.conf

echo -e "\033[36m<<<<<===== sshd config =====>>>>>\033[0m"
mv /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
mv sshd_config /etc/ssh/sshd_config
systemctl restart ssh
systemctl enable --now ssh

echo -e "\033[36m<<<<<===== UFW config =====>>>>>\033[0m"
ufw default deny
ufw allow 22122/tcp
ufw --force enable
systemctl enable --now ufw

read -p "Press enter to continue"
echo -e "\033[36m<<<<<===== fail2ban config =====>>>>>\033[0m"
systemctl start fail2ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
mv jail.local /etc/fail2ban/jail.local
read -p "Press enter to continue"
systemctl reload fail2ban
systemctl enable fail2ban
fail2ban-client status
fail2ban-client status sshd

read -p "Press enter to continue"
echo -e "\033[36m<<<<<===== rkhunter config =====>>>>>\033[0m"
mv /etc/rkhunter.conf /etc/rkhunter.conf_backup
mv rkhunter.conf /etc/rkhunter.conf
rkhunter -C
rkhunter --update
rkhunter --propupd

read -p "Press enter to continue"
echo -e "\033[36m<<<<<===== Add and config sudo user =====>>>>>\033[0m"
read -p "User name: " user_sudo
useradd -m -G sudo -s /usr/bin/zsh $user_sudo
passwd $user_sudo
mkdir /home/$user_sudo/.ssh
touch /home/$user_sudo/.ssh/authorized_keys
chown $user_sudo:$user_sudo /home/$user_sudo/.ssh /home/$user_sudo/.ssh/authorized_keys
vim /home/$user_sudo/.ssh/authorized_keys

read -p "Press enter to continue"
echo -e "\033[36m<<<<<===== Add ansible user? /// 'Y'es /// /// 'N'o /// =====>>>>>\033[0m"
read -p "Add?: " ansible_user
echo "You've decided: "$ansible_user

if [[ $ansible_user = Y ]]; then
    useradd -m -G sudo ansible
    passwd ansible
    mkdir /home/ansible/.ssh
    touch /home/ansible/.ssh/authorized_keys
    chown ansible:ansible /home/ansible/.ssh /home/ansible/.ssh/authorized_keys
    vim /home/ansible/.ssh/authorized_keys

    echo -e "\033[36m<<<<<===== Final config =====>>>>>\033[0m"
    read -p "Press enter to continue"
    shred -zun 3 config.sh

elif [[ $ansible_user = N ]]; then
    echo -e "\033[36m<<<<<===== Final config =====>>>>>\033[0m"
    read -p "Press enter to continue"
    shred -zun 3 config.sh

fi
