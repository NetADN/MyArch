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
	SSID=sed -n '1' wifi.txt
	WPA=sed -n '2' wifi.txt
	nmcli dev wifi connect $SSID password $WPA
	sleep 10
}
check_wifi() {
	ping -q -c 2 google.fr >/dev/null 2>&1 
	if [ $? -eq 0 ]; then 
	  print_warning "Vous êtes connecté à internet." 
	else 
	  print_warning "Vous n'êtes pas connecté à internet." 
	fi 
}

print_title "Arch Linux Script Auto-Install FR 3/3 (beta)"

for ((i=0 ; $i < 3; i++))

    do read -p "Lancer l'installation: [oui|non] : " START 

    if [ $START == 'Oui' ] || [ $START == 'OUI' ] || [ $START == 'O' ] || [ $START == 'o' ] || [ $START == 'oui' ]; then
	
		systemctl stop dhcpcd.service 
		systemctl start NetworkManager.service
		systemctl enable NetworkManager.service
		sleep 10

		FILE_WIFI="/root/wifi.txt"
		if [ -f "$FILE_WIFI" ]; then
			config_wifi
			check_wifi
		fi
		print_info "Activation du WIFI : OK" sleep 1

    	read -p "Tappez oui pour ajouter les dépots Arch User Repository : " DEPOT_AUR 
		if [ $DEPOT_AUR == 'Oui' ] || [ $DEPOT_AUR == 'OUI' ] || [ $DEPOT_AUR == 'O' ] || [ $DEPOT_AUR == 'o' ] || [ $DEPOT_AUR == 'oui' ]; then
			echo "[archlinuxfr]" >> /etc/pacman.conf
			echo "SigLevel = Never" >> /etc/pacman.conf
			echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
			pacman -Syu
			sleep 1
			pacman -S yaourt
			print_info "Configuration des dépots Arch User Repository : OK" sleep 1
		fi

		pacman -S --noconfirm alsa-utils alsa-oss pulseaudio-alsa gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav xorg-server xorg-xinit xorg-xmessage xorg-utils xorg-server-utils ttf-bitstream-vera ttf-freefont ttf-dejavu ttf-liberation xf86-input-mouse xf86-input-keyboard xf86-input-synaptics xf86-video-intel acpi powertop cpupower hdparm iw unzip zip unrar p7zip dosfstools mtools ntfs-3g wget gnome gnome-keyring shotwell firefox-i18n-fr
		systemctl enable gdm
		print_info "Installation des dépendances : OK" sleep 1

		read -p "Tappez oui pour activer le bluetooth : " BT
		if [ $BT == 'Oui' ] || [ $BT == 'OUI' ] || [ $BT == 'O' ] || [ $BT == 'o' ] || [ $BT == 'oui' ]; then
			systemctl enable bluetooth
			print_info "Activation du bluetooth : OK" sleep 1
		fi

		FILE_USER="/root/user.txt"
		if [ -f "$FILE_USER" ]; then
			print_warning "Entrez le mot de passe du compte $NAME_USER"
			NAME_USER=sed -n '1' user.txt
			sudo su - $NAME_USER << EOF
		        sudo pacman -S --noconfirm xdg-user-dirs
		        localectl set-x11-keymap fr
		        yaourt -S google-chrome
			EOF
			rm /root/user.txt
		fi

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
		systemctl start iptables
		systemctl enable iptables
		print_info "Configuration du pare-feu : OK" sleep 1	

		sudo rm /root/script-install-*
		FILE_CONFIG_WIFI="/etc/netctl/wifi"
		if [ -f "$FILE_CONFIG_WIFI" ]; then
			rm /etc/netctl/wifi
		fi
		FILE_WIFI="/root/wifi.txt"
		if [ -f "$FILE_WIFI" ]; then
			rm /root/wifi.txt
		fi
		print_info "Nettoyage des fichiers d'instalaltion : OK" sleep 1
	
		print_title "Arch Linux Script Auto-Install 3/3 terminé avec succès. Veuillez redémarrer pour finaliser votre installation."
		sleep 10

    	exit 0

    elif [ $START == 'Non' ] || [ $START == 'NON' ] || [ $START == 'N' ] || [ $START == 'n' ] || [ $START == 'non' ]; then
    	exit 0
    else 
    	echo "Choix non valide"
    fi
done
exit 0
