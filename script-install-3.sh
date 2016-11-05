#!/bin/sh

clear
echo "############################"
echo "## INSTALL ARCH LINUX 3/3 ##"
echo "############################"
systemctl stop dhcpcd.service
sleep 2
systemctl start NetworkManager.service
sleep 2
systemctl enable NetworkManager.service
sleep 10
nmcli dev wifi connect $1 password $2
sleep 10

echo "---------------------------"
echo "WIFI NetworkManager : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

echo "Ajout des dépots AUR"
echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
pacman -Syu
sleep 2
pacman -S yaourt
echo "---------------------------"
echo "Ajout des dépot AUR : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

echo "Installation des dépendances"
echo "Entrer votre mot de pass : "
pacman -S --noconfirm alsa-utils alsa-oss pulseaudio-alsa
echo "---------------------------"
echo "Install sound Alsa : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

pacman -S --noconfirm gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
echo "---------------------------"
echo "Install plugin : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

pacman -S --noconfirm xorg-server xorg-xinit xorg-xmessage xorg-utils xorg-server-utils
echo "---------------------------"
echo "Install server X : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

pacman -S --noconfirm ttf-bitstream-vera ttf-freefont ttf-dejavu ttf-liberation 
echo "---------------------------"
echo "Install fonts : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

pacman -S --noconfirm xf86-input-mouse xf86-input-keyboard xf86-input-synaptics xf86-video-intel
echo "---------------------------"
echo "Install drivers : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

pacman -S --noconfirm acpi powertop cpupower hdparm iw unzip zip unrar p7zip dosfstools mtools ntfs-3g wget
echo "---------------------------"
echo "Install tools : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

systemctll enable bluetooth
sleep 1
echo "---------------------------"
echo "Bluetooth : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

iptables -t filter -F
iptables -t filter -X

iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

iptables -t filter -A OUTPUT -p udp -m udp --dport 53 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT 
iptables -t filter -A INPUT -p udp -m udp --sport 53 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 192.168.0.0/24 -p icmp -j ACCEPT
iptables -A INPUT -s 192.168.0.0/24 -p icmp -j ACCEPT

iptables -t filter -A OUTPUT -p tcp -m multiport --dports 80,443,8000 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT  
iptables -t filter -A INPUT -p tcp -m multiport --sports 80,443,8000 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

iptables -t filter -A OUTPUT -o lo -j ACCEPT
iptables -t filter -A INPUT -i lo -j ACCEPT

iptables-save > /etc/iptables/iptables.rules
sleep 1

systemctl start iptables
sleep 1
systemctl enable iptables
sleep 1
echo "---------------------------"
echo "Par feu actif : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

sudo su - netadn << EOF
	echo "---------------------------"
	echo "Connexion user account : OK"
	echo "---------------------------"
	echo ""
	echo ""
	sleep 2

        cd ~/
        sudo pacman -S --noconfirm xdg-user-dirs gnome gnome-keyring shotwell 
        localectl set-x11-keymap fr
        systemctl enable gdm
        echo "---------------------------"
	echo "Installation de gnome  : OK"
	echo "---------------------------"
	echo ""
	echo ""
	sleep 2

	yaourt -S google-chrome firefox-i18n-fr
        echo "---------------------------"
	echo "Installation des naviguateurs  : OK"
	echo "---------------------------"
	echo ""
	echo ""
	wget http://img0.gtsstatic.com/wallpapers/4afa7b0360d9e260a1b99ca471eea298_large.jpeg
	mv 4afa7b0360d9e260a1b99ca471eea298_large.jpeg /home/netadn/.config/wallpaper.jpg
	sleep 2

EOF
echo""
echo "---------------------------"
echo "Switch to root account : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

sudo rm /root/script-install-*
echo""
echo "---------------------------"
echo "Nettoyage file install : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

echo "############################"
echo " END OFF INSTALL ARCH LINUX "
echo "############################"
echo ""
echo ""
echo "Reboot dans 5 secondes..."
sleep 5
reboot
