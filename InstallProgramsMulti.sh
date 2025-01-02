#!/bin/bash
#Color variables for error ouput
export Red='\e[38;5;196m'
export Reset='\033[0m'
export Cyan='\e[38;5;87m'
#other variables
export whichOS=$(cat /etc/*release | grep PRETTY_NAME | cut -d '=' -f2- | tr -d '"' | awk '{print $1}')
# Make sure this script is run as root
if [[ $EUID -eq 0 ]]; then
    echo
    echo -e "${Red}Don't run this script as root. It can mess up your system${Reset}" 1>&2
    echo
    exit
fi
wait
#Should make it so that we have to fill in our PW only once
read -p "Password: " -s PWonce
#First lets make sure our system is updated
#First lets do a first time update of our system
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -Syu --noconfirm
elif [[ "$whichOS" == "Rocky" ]]; then
    printf "%s\n" "$PWonce" | sudo -S dnf update && sudo dnf upgrade
elif [[ "$whichOS" == "Ubuntu" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt update && sudo apt upgrade
elif [[ "$whichOS" == "Debian" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt-get update && sudo apt-get upgrade
else
    clear
    echo -e "${Red}Cant update system since your OS is not supported by this script!${Cyan}"
    echo -e "${Cyan}You have ${Red}${whichOS}${Cyan}installed."
    echo -e "${Red}Please update manually before continuing this script${Cyan}"
    sleep 10
fi
wait
#Install curl and wget:
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S curl --needed --noconfirm
    printf "%s\n" "$PWonce" | sudo -S pacman -S wget --needed --noconfirm
elif [[ "$whichOS" == "Debian" | "$whichOS" == "Ubuntu" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install curl -y
    printf "%s\n" "$PWonce" | sudo -S apt install wget -y
elif [[ "$whichOS" == "Rocky" ]]; then
    printf "%s\n" "$PWonce" | sudo -S dnf install curl -y
    printf "%s\n" "$PWonce" | sudo -S dnf install wget -y
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
    sleep 5
fi
#Before we are gong to install yay, lets download dependencies
#This way makepkg wont invoke pw for dependencies
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S go --noconfirm --needed
    wait
#Let's first install yay; a packet manager
    git clone https://aur.archlinux.org/yay.git
    wait
    cd yay
    makepkg -s --noconfirm --needed
    wait
    printf "%s\n" "$PWonce" | sudo -S pacman -U *.pkg.tar.zst --noconfirm
    wait
#Now let's update yay; NEVER RUN 'yay -Syu' as SUDO or ROOT!!!
    yay -Syu --noconfirm
    wait
else
    echo -e "${Red}You don't have Arch Linux; Can't install yay!${Cyan}"
    sleep 5
fi
#Let's install our programs
#Install Brave Browser
if [[ "$whichOS" == "Arch" ]]; then
    yay -S brave-bin --needed --noconfirm
elif [[ "$whichOS" == "Debian" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install curl
    wait
    printf "%s\n" "$PWonce" | sudo -S curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    wait
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    wait
    printf "%s\n" "$PWonce" | sudo -S apt update -y
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install brave-browser -y
    wait
elif [[ "$whichOS" == "Ubuntu" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install curl -y
    wait
    printf "%s\n" "$PWonce" | sudo -S curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    wait
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    wait
    printf "%s\n" "$PWonce" | sudo -S apt update
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install brave-browser
    wait
elif [[ "$whichOS" == "Rocky" ]]; then
    printf "%s\n" "$PWonce" | sudo -S dnf install dnf-plugins-core
    wait
    printf "%s\n" "$PWonce" | sudo -S dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    wait
    printf "%s\n" "$PWonce" | sudo -S dnf install brave-browser
    wait
else
    echo -e "${Cyan}Your OS: ${Red}${whichOS}${Cyan} is not yet supported by this script."
    echo -e "${Red}Script will continue...${Cyan}"
    sleep 3
fi
#Install Steam
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S steam --needed --noconfirm
elif [[ "$whichOS" == "Debian" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install software-properties-common apt-transport-https dirmngr ca-certificates curl -y
    printf "%s\n" "$PWonce" | sudo -S dpkg --add-architecture i386 && sudo apt update
    curl -s http://repo.steampowered.com/steam/archive/stable/steam.gpg | sudo tee /usr/share/keyrings/steamgpg > /dev/null
    echo deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] http://repo.steampowered.com/steam/ stable steam | sudo tee /etc/apt/sources.list.d/steam.list
    printf "%s\n" "$PWonce" | sudo -S apt update -y
    printf "%s\n" "$PWonce" | sudo -S apt install libgl1-mesa-dri:amd64 -y
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install libgl1-mesa-dri:i386 -y
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install libgl1-mesa-glx:amd64 -y
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install libgl1-mesa-glx:i386 -y
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install steam-launcher -y
elif [[ "$whichOS" == "Ubuntu" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install steam -y
else
    echo -e "${Cyan}You have another distro, OS: ${Red}${whichOS}${Cyan}"
    echo -e "${Red}You have to install manually!${Cyan}"
    sleep 5
fi
#Install Discord
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S discord --needed --noconfirm
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Install Spotify
if [[ "$whichOS" == "Arch" ]]; then
    yay -S spotify --needed --noconfirm
elif [[ "$whichOS" == "Debian" | "$whichOS" == "Ubuntu" ]]; then
    printf "%s\n" "$PWonce" | sudo -S curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    wait
    printf "%s\n" "$PWonce" | sudo -S echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    wait
    printf "%s\n" "$PWonce" | sudo -S apt-get update && printf "%s\n" "$PWonce" | sudo -S apt-get install spotify-client -y
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi  
#Install Google Chrome ---> Check if they all work
if [[ "$whichOS" == "Arch" ]]; then
    yay -S google-chrome --needed --noconfirm
elif [[ "$whichOS" == "Debian" ]]; then
    printf "%s\n" "$PWonce" | sudo -S curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    wait
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    wait
    printf "%s\n" "$PWonce" | sudo -S apt update
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install google-chrome-stable
elif [[ "$whichOS" == "Ubuntu" ]]; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    wait
    printf "%s\n" "$PWonce" | sudo -S dpkg -i google-chrome-stable_current_amd64.deb
    wait
    printf "%s\n" "$PWonce" | sudo -S apt install -f
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Install NordVPN
if [[ "$whichOS" == "Arch" ]]; then
    yay -S nordvpn-bin --needed --noconfirm
elif [[ "$whichOS" == "Debian" | "$whichOS" == "Ubuntu" | "$whichOS" == "Rocky" ]]; then
    sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) #sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)   ---> Different one if the curl one doesnt work
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi    
#Install Teamspeak3
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S teamspeak3 --needed --noconfirm
else
    echo -e "${Red}No normal installer available${Cyan}"
    echo -e "${Cyan}You can go to ${Red}teamspeak.com${Cyan} & download the 64bit linux client${Cyan}"
    sleep 5
fi
#Install Telegram Desktop App
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S telegram-desktop --needed --noconfirm
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi  
#Install Geany (notepad)
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S geany --needed --noconfirm
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Install OpenTabletDriver
#First lets install dependencies
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S netstandard-targeting-pack dotnet-targeting-pack netstandard-targeting-pack oniguruma dotnet-sdk libcom_err.so libverto-module-base sh libreadline.so libgdbm.so libncursesw.so gcc-libs glibc icu krb5 libunwind linux-api-headers openssl zlib bash e2fsprogs keyutils libcom_err.so libldap lmdb xz libsasl readline util-linux-libs gdbm ncurses sqlite jq --noconfirm
    wait
    printf "%s\n" "$PWonce" | sudo -S pacman -S dotnet-runtime dotnet-host --needed --noconfirm
# Downloads the pkgbuild from the AUR.
    git clone https://aur.archlinux.org/opentabletdriver.git
    wait
# Changes into the correct directory, pulls needed dependencies, then installs OpenTabletDriver
    cd opentabletdriver
    wait
    makepkg -s --noconfirm --needed
    wait
    printf "%s\n" "$PWonce" | sudo -S pacman -U *.pkg.tar.zst --noconfirm
# Clean up leftovers
    cd ..
    rm -rf opentabletdriver
    wait
# Regenerate initramfs
    printf "%s\n" "$PWonce" | sudo -S mkinitcpio -P
    wait
# Unload kernel modules
    printf "%s\n" "$PWonce" | sudo -S rmmod wacom hid_uclogic
    wait
#Enable Opentabletdriver
    systemctl --user enable opentabletdriver.service --now
    wait
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Install 1password
if [[ "$whichOS" == "Arch" ]]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
    wait
    git clone https://aur.archlinux.org/1password.git
    wait
    cd 1password
    wait
    makepkg -s --noconfirm --needed
    printf "%s\n" "$PWonce" | sudo -S pacman -U *.pkg.tar.zst --noconfirm
elif [[ "$whichOS" == "Debian" | "$whichOS" == "Ubuntu" ]]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    wait
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    wait
    printf "%s\n" "$PWonce" | sudo -S mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    wait
    printf "%s\n" "$PWonce" | sudo -S curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    wait
    printf "%s\n" "$PWonce" | sudo -S mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    wait
    printf "%s\n" "$PWonce" | sudo -S curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    wait
    printf "%s\n" "$PWonce" | sudo -S apt update && sudo apt install 1password
elif [[ "$whichOS" == "Rocky" ]]; then
    printf "%s\n" "$PWonce" | sudo -S rpm --import https://downloads.1password.com/linux/keys/1password.asc
    wait
    printf "%s\n" "$PWonce" | sudo -S sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
    wait
    sudo dnf install 1password
    wait
elif [[ "$whichOS" == "openSUSE" ]]; then
   printf "%s\n" "$PWonce" | sudo -S rpm --import https://downloads.1password.com/linux/keys/1password.asc
    wait
    printf "%s\n" "$PWonce" | sudo -S zypper addrepo https://downloads.1password.com/linux/rpm/stable/x86_64 1password
    wait
    printf "%s\n" "$PWonce" | sudo -S zypper install 1password
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Install everything needed for QEMU/KVM Virtmanager
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned --noconfirm --needed
    wait
#Enable services for Virtmanager
    printf "%s\n" "$PWonce" | sudo -S systemctl enable libvirtd.service
    wait
    printf "%s\n" "$PWonce" | sudo -S systemctl start libvirtd.service
    echo -e "${Cyan}QEMU/KVM Virtmanager has been installed"
    wait
#Enable virt manager thing that causes an error after a reboot and you want to start it:
printf "%s\n" "$PWonce" | sudo -S virsh net-autostart default
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#Installing VIM (if it's not yet on there already)
if [[ "$whichOS" == "Arch" ]]; then
    printf "%s\n" "$PWonce" | sudo -S pacman -S vim --needed --noconfirm
    wait
elif [[ "$whichOS" == "Ubuntu" | "$whichOS" == "Debian" ]]; then
    printf "%s\n" "$PWonce" | sudo -S apt install vim -y
elif [[ "$whichOS" == "Rocky" ]]; then
    printf "%s\n" "$PWonce" | sudo -S dnf install vim -y
else
    echo -e "${Red}No support for your OS at the moment! Maybe it will be added at a later time.${Cyan}"
fi
#VIM Configuration:
mv -i /home/$USER/ArchInstallScript/.vimrc /home/$USER/
#Installing the part that is needed to share clipboard for VM's
#printf "%s\n" "$PWonce" | sudo -S pacman -S spice-vdagent
#End of script
echo -e "${Cyan}Everything has been installed.${Reset}"
sleep 2
echo -e "${Cyan}Exiting script!${Reset}"
sleep 2
