# MyArch


### How to use

Boot with iso Archlinux

Connect to the network

cd /root

wget https://raw.githubusercontent.com/NetADN/MyArch/master/script-install-1.sh

wget https://raw.githubusercontent.com/NetADN/MyArch/master/script-install-2.sh

wget https://raw.githubusercontent.com/NetADN/MyArch/master/script-install-3.sh

wget https://raw.githubusercontent.com/NetADN/MyArch/master/config


chmod +x script-* && chmod config

Edit the file config

./script-install-1.sh && arch-chroot /mnt /bin/bash

./root/script-install-2.sh

exit

swapoff && umont -R /mtn && reboot

After reboot

./root/script-install-3.sh



