#!/bin/bash

set -e -u

##Gen locales
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
#echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

##Set timezone - Set to US Pacific -8
ln -sf /usr/share/zoneinfo/US/Pacific-New /etc/localtime

##Configure root user, password = toor
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root
echo -e "toor\ntoor" | passwd root

##Add base user, password = password
useradd -m -G wheel user || echo "User exists"
echo -e "password\npassword" | passwd user
## Add user to sudo
echo 'user ALL=(ALL:ALL) ALL' >> /etc/sudoers
## Change user shell to zsh
chsh -s /bin/zsh user

##Fix permissions
chown -R user /home/user/images
chown -R user /home/user/.config

##zsh config - need to run as user somehow
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

##Misc services
#sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

##Enable system services
systemctl enable pacman-init.service choose-mirror.service
systemctl enable tlp

##Set graphical for lightdm
systemctl set-default graphical.target
systemctl enable lightdm.service