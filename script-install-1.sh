#!/bin/sh

# Avant de lancer le script configurer 
# vos partitions pour correspondre au script
# vos paramètres de connexion wifi

# PARTITION DU HDD
# UEFI -> /dev/sda1 (type partition vfat)
# swap -> /dev/arch/swap (type partition lvm)
# root -> /dev/arch/root (type partition lvm)
# srv  -> /dev/arch/srv (type partition lvm)
# home -> /dev/arch/home (type partition lvm)





clear
echo "############################"
echo "## INSTALL ARCH LINUX 1/3 ##"
echo "############################"





loadkeys fr
echo "---------------------------"
echo "clavier Fr : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2






echo "Connexion wifi en cours..."
touch /etc/netctl/wifi
cat > /etc/netctl/wifi <<EOL
Description="Starting Wifi Network $ssid"
Interface=$interface
Connection=wireless
Security=wpa
IP=dhcp
ESSID="$ssid"
Key="$wpa"
Hidden="$hidden"

EOL
netctl start wifi
sleep 5
echo "---------------------------"
echo "Connexion wifi : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2





pacman -Sy
echo "---------------------------"
echo "Mise à jour des paquets : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2





echo "Formatage boot en cours..."
mkfs.fat -F32 /dev/sda1
echo ""
echo "Formatage swap en cours..."
mkswap /dev/arch/swap
echo ""
echo "Formatage root en cours..."
mkfs.ext4 /dev/arch/root
echo ""
echo "Formatage srv en cours..."
mkfs.ext4 /dev/arch/srv
echo ""
echo "Formatage home en cours..."
mkfs.ext4 /dev/arch/home
echo "----------------------------"
echo "Formatage des partitions: OK"
echo "----------------------------"
echo ""
echo ""
sleep 2





swapon /dev/arch/swap
echo "----------------------------"
echo "Activation du swap : OK"
echo "----------------------------"
echo ""
echo ""
sleep 2





mount -o discard,noatime /dev/arch/root /mnt
sleep 1
mkdir -p /mnt/{boot,srv,home}
mount /dev/sda1 /mnt/boot
sleep 1
mount -o discard,noatime /dev/arch/srv /mnt/srv
sleep 1
mount -o discard,noatime /dev/arch/home /mnt/home
sleep 1
echo "-----------------------------"
echo "Montage des partitions : OK"
echo "-----------------------------"
echo ""
echo ""
sleep 2






pacstrap -i /mnt base base-devel
echo "-----------------------------"
echo "Environnement de chroot : OK"
echo "-----------------------------"
echo ""
echo ""
sleep 2





cp /root/script-install* /mnt/root/
cp /root/config /mnt/root/
echo "-----------------------------"
echo "Copies scripts post install: OK"
echo "-----------------------------"
echo ""
echo ""
sleep 2






genfstab -U -p /mnt >> /mnt/etc/fstab
echo "-----------------------------"
echo "File fstab : OK"
echo "-----------------------------"
echo ""
echo ""
sleep 2






echo "############################"
echo "INSTALL ARCH LINUX 1/3  OK"
echo "############################"

echo "Veuilez executer la ligne de"
echo "ci-dessous pour passer dans"
echo "l'environement chrootet"

echo ""
echo "-> arch-chroot /mnt /bin/bash"
echo "ENSUITE EXECUTER SCRIPT 2/3"