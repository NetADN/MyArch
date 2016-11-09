#!/bin/sh
clear

Bold=$(tput bold)
BRed=${Bold}$(tput setaf 1)
BYellow=${Bold}$(tput setaf 3)
Reset=$(tput sgr0)

print_line() {
    printf "%$(tput cols)s\n"|tr ' ' '-'
}
print_title() {
    print_line
    echo -e "# ${Bold}$1${Reset}"
    print_line
    echo ""
}
print_info() {
    T_COLS=`tput cols`
    echo -e "${Bold}$1${Reset}\n" | fold -sw $(( $T_COLS - 18 )) | sed 's/^/\t/'
}
print_danger() {
	T_COLS=`tput cols`
    echo -e "${BRed}$1${Reset}\n" | fold -sw $(( $T_COLS - 1 )) | sed 's/^/\t/'
} 
print_warning() {
    T_COLS=`tput cols`
    echo -e "${BYellow}$1${Reset}\n" | fold -sw $(( $T_COLS - 1 ))
}

print_title "Arch Linux Script Auto-Install FR 2/3 (beta)"

for ((i=0 ; $i < 3; i++))

    do read -p "Lancer l'installation: [oui|non] : " START 

    if [ $START == 'Oui' ] || [ $START == 'OUI' ] || [ $START == 'O' ] || [ $START == 'o' ] || [ $START == 'oui' ]; then

		echo archlinux > /etc/hostname
		echo '127.0.0.1 localhost.localdomain localhost archlinux' > /etc/hosts
		echo '::1 localhost.localdomain localhost archlinux' >> /etc/hosts
		print_info "Creation du fichier hostname : OK" sleep 1

		ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
		hwclock --systohc --utc
		print_info "Configuration de l'heure du system : OK" sleep 1

		echo 'KEYMAP=fr-pc' > /etc/vconsole.conf
		print_info "Configuration du mappage clavier (azerty) : OK" sleep 1

		echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen
		echo 'LANG=fr_FR.UTF-8' > /etc/locale.conf
		echo 'LC_COLLATE=C' >> /etc/locale.conf
		export LANG=fr_FR.UTF-8
		locale-gen
		print_info "Langue du systeme Fr : OK" sleep 1

		sed -i.bak s/"base udev autodetect modconf block filesystems keyboard fsck"/"base udev resume autodetect modconf block lvm2 filesystems keyboard fsck"/g /etc/mkinitcpio.conf
		mkinitcpio -p linux
		print_info "Création du noyau GNU/Linux : OK" sleep 1
	
		pacman -Syu intel-ucode wpa_supplicant networkmanager
		print_info "Installation des dépendances minimales : OK" sleep 1
	
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
		print_info "Configuration du boot UEFI : OK" sleep 1

		print_warning "Entrez le mot de passe du compte root : "
		passwd 
		print_info "Création du mot de passe root : OK" sleep 1

    	read -p "Tappez oui pour ajouter un nouvel utilisateur : " NEW_USER 
		if [ $NEW_USER == 'Oui' ] || [ $NEW_USER == 'OUI' ] || [ $NEW_USER == 'O' ] || [ $NEW_USER == 'o' ] || [ $NEW_USER == 'oui' ]; then
			read -p "Entrez le nom du nouvel utilisateur : " NAME_NEW_USER
			useradd -m -g users -G wheel -c "$NAME_NEW_USER" -s /bin/bash $NAME_NEW_USER
			print_info "Entrez le mot de passe du compte utilisateur : "
			passwd $NAME_NEW_USER
			print_warning "Décommenter cette ligne ${Bold}\"%wheel ALL=(ALL) ALL\"${Reset} pour donner les droits administrateur au nouveau compte."
			sleep 10
			EDITOR=nano visudo
		fi

		print_warning "Veuillez lancer ${Bold}\"exit\"${Reset} les commandes ci-dessous pour sortir de l'environnement chroot. Ensuite tappez ${Bold}\"umount -R /mnt && swapoff /dev/arch/swap\"${Reset} pour démonter proprement les partitions et redémarrer à l'aide de la commande ${Bold}\"reboot\"${Reset}. Au redémarage de l'ordinateur pensez à utiliser le nouveau mot de passe pour vous connecter. Puis lancer le script Auto-Install 3/3 pour terminer l'installation d'Arch Linux."
		sleep 10

    	exit 0
    elif [ $START == 'Non' ] || [ $START == 'NON' ] || [ $START == 'N' ] || [ $START == 'n' ] || [ $START == 'non' ]; then
    	exit 0
    else 
    	echo "Choix non valide"
    fi
done
exit 0
