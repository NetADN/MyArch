#!/bin/sh
clear
echo "############################"
echo "## INSTALL ARCH LINUX 2/3 ##"
echo "############################"

echo archlinux > /etc/hostname
echo '127.0.0.1 localhost.localdomain localhost archlinux' > /etc/hosts
echo '::1 localhost.localdomain localhost archlinux' >> /etc/hosts
echo "---------------------------"
echo "hostname : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc
echo "---------------------------"
echo "horloge du system : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

echo 'KEYMAP=fr-pc' > /etc/vconsole.conf
echo "---------------------------"
echo "Config du clavier : OK"
echo "---------------------------"
echo ""
echo ""
sleep 2

echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen
echo 'LANG=fr_FR.UTF-8' > /etc/locale.conf
echo 'LC_COLLATE=C' >> /etc/locale.conf
export LANG=fr_FR.UTF-8
locale-gen
echo "----------------------------"
echo "Langue du system : OK"
echo "----------------------------"
echo ""
echo ""
sleep 2

echo "Creation du noyau en cours..."
sed -i.bak s/"base udev autodetect modconf block filesystems keyboard fsck"/"base udev resume autodetect modconf block lvm2 filesystems keyboard fsck"/g /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "-----------------------------"
echo "Generation du noyau GNU/Linux"
echo "-----------------------------"
echo ""
echo 
sleep 2

echo "Install dependance en cours..."
pacman -Syu intel-ucode wpa_supplicant networkmanager
echo "-----------------------------"
echo "Instalation dependance : OK"
echo "-----------------------------"
echo ""
echo ""
sleep 2

bootctl install
rm /boot/loader/loader.conf
echo 'default arch' > /boot/loader/loader.conf
cat > /boot/loader/entries/arch.conf <<EOL
titile   Arch Linux
linux    /vmlinuz-linux
initrd   /intel-ucode.img
initrd   /initramfs-linux.img
options  root=/dev/arch/root rw resume=/dev/arch/swap quiet
EOL
rm -R /boot/EFI/boot
bootctl update
echo "-----------------------------"
echo "Configuration boot UEFI : oK"
echo "-----------------------------"
echo ""
echo ""
sleep 2

echo "Tapez mot de passe root"
passwd
echo "----------------------------"
echo "Mot de passe root : OK"
echo "----------------------------"
echo ""
echo ""
sleep 2

echo "Ajout d'un compte utilisateur"
useradd -m -g users -G wheel  -c 'Sebastien Martinez' -s /bin/bash netadn
echo "Entrer mot de passe du compte utilisateur : "
passwd netadn
sleep 1
EDITOR=nano visudo
echo "----------------------------"
echo "Utilisateur : OK"
echo "----------------------------"
echo ""
echo ""
sleep 2

echo "############################"
echo "INSTALL ARCH LINUX 2/3  OK"
echo "############################"


echo "Veuilez demonterles partitions avant de rebooter"
echo ""
echo "-> exit && umount -R /mnt && swapoff /dev/arch/swap"
echo "ENSUITE REBOOTER CONFIGURER LE SSID ET LA CLEF WPA AVANT D'EXECUTER lE SCRIPT 3/3"
sleep 10
