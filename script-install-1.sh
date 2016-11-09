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
config_wifi() {
	touch /etc/netctl/wifi
	cat > /etc/netctl/wifi <<EOL
	Description="Starting Wifi Network $1"
	Interface=wlp2s0
	Connection=wireless
	Security=wpa
	IP=dhcp
	ESSID="$1"
	Key="$2"
	Hidden=yes
EOL
}
check_wifi() {
	ping -q -c 2 google.fr >/dev/null 2>&1 
	if [ $? -eq 0 ]; then 
	  print_warning "Vous êtes connecté à internet." 
	else 
	  print_warning "Vous n'êtes pas connecté à internet." 
	fi 
}

print_title "Arch Linux Script Auto-Install FR 1/3 (beta)"
print_danger "Attention ! Si vous lancez le script d'installation les données présent sur votre disque dur seront perdus."


for ((i=0 ; $i < 3; i++))

    do read -p "Lancer l'installation: [oui|non] : " START 

    if [ $START == 'Oui' ] || [ $START == 'OUI' ] || [ $START == 'O' ] || [ $START == 'o' ] || [ $START == 'oui' ]; then
		loadkeys fr-pc
		print_info "Configuration du clavier FR : OK" sleep1


		if [ $# -eq 2 ]; then
			config_wifi
			check_wifi
			netctl start wifi
			sleep 10
		fi

		gdisk /dev/sda x z y w
		(
			echo x
			echo z
			echo y
			echo w
		) | gdisk
		(
			echo n
			echo 1
			echo 
			echo +512M
			echo EF00
			echo n
			echo 2
			echo 
			echo 
			echo 8e00
			echo w
		) | gdisk

		pvcreate -f /dev/sda2
		vgcreate -f arch
		lvcreate -L 4G arch -n swap
		lvcreate -L 26G arch -n root
		lvcreate -L 10G arch -n srv
		lvcreate -l 100%FREE -n home arch
		print_info "Creation des partitions lvm : OK" sleep 1


		mkfs.fat -F -F32 /dev/sda1
		mkswap -f /dev/arch/swap
		mkfs.ext4 -F /dev/arch/root
		mkfs.ext4 -F /dev/arch/srv
		mkfs.ext4 -F /dev/arch/home
		print_info "Formatage des partitions du system : OK" sleep 1

		swapon /dev/arch/swap
		print_info "Activation du swap : OK" sleep 1

		mount -o discard,noatime /dev/arch/root /mnt
		mkdir -p /mnt/{boot,srv,home}
		mount /dev/sda1 /mnt/boot
		mount -o discard,noatime /dev/arch/srv /mnt/srv
		mount -o discard,noatime /dev/arch/home /mnt/home
		print_info "Montage des partitions : OK" sleep 1

		pacstrap -i /mnt base base-devel
		cp /root/script-install* /mnt/root/
		print_info "Environnement chroot : OK" sleep 1


		genfstab -U -p /mnt >> /mnt/etc/fstab
		print_info "Création du fichier fstab : OK" sleep 1

		print_info "Veuillez executer la comande ci-dessous pour switcher dans votre nouveau système. Une fois arrivé dans votre nouvel environnement lancer le script d'installation 2/3."
		print_warning "arch-chroot /mnt /bin/bash"

		print_title "Installation 1/3 terminé avec succès"
		sleep 10

    	exit 0
    elif [ $START == 'Non' ] || [ $START == 'NON' ] || [ $START == 'N' ] || [ $START == 'n' ] || [ $START == 'non' ]; then
    	exit 0
    else 
    	echo "Choix non valide"
    fi
done
exit 0
