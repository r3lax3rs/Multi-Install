#!/bin/bash
#Color variables for error ouput
export Red='\e[38;5;196m'
export Reset='\033[0m'
export Cyan='\e[38;5;87m'
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
printf "%s\n" "$PWonce" | sudo -S pacman -Syu --noconfirm
wait
#Before we are gong to install yay, lets download dependencies
#This way makepkg wont invoke pw for dependencies
printf "%s\n" "$PWonce" | sudo -S pacman -S go --noconfirm --needed
wait
#Let's first install yay; a packet manager
git clone https://aur.archlinux.org/yay.git
wait
cd yay
makepkg -s --noconfirm --needed
wait
printf "%s\n" "$PWonce" | sudo -S pacman -U *.pkg.tar.zst --noconfirm
#Now let's update yay; NEVER RUN 'yay -Syu' as SUDO or ROOT!!!
yay -Syu --noconfirm
wait
#Let's install our programs
#Install Brave Browser
yay -S brave-bin --needed --noconfirm
#Install Steam
printf "%s\n" "$PWonce" | sudo -S pacman -S steam --needed --noconfirm
#Install Discord
printf "%s\n" "$PWonce" | sudo -S pacman -S discord --needed --noconfirm
#Install Spotify
yay -S spotify --needed --noconfirm
#Install Google Chrome
yay -S google-chrome --needed --noconfirm
#Install NordVPN
yay -S nordvpn-bin --needed --noconfirm
#Install Teamspeak3
printf "%s\n" "$PWonce" | sudo -S pacman -S teamspeak3 --needed --noconfirm
#Install Telegram Desktop App
printf "%s\n" "$PWonce" | sudo -S pacman -S telegram-desktop --needed --noconfirm
#Install Geany (notepad)
printf "%s\n" "$PWonce" | sudo -S pacman -S geany --needed --noconfirm
#Install curl
printf "%s\n" "$PWonce" | sudo -S pacman -S curl --needed --noconfirm
#Install OpenTabletDriver
#First lets install dependencies
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
#Install 1password
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
wait
git clone https://aur.archlinux.org/1password.git
wait
cd 1password
wait
makepkg -s --noconfirm --needed
printf "%s\n" "$PWonce" | sudo -S pacman -U *.pkg.tar.zst --noconfirm
#Install everything needed for QEMU/KVM Virtmanager
printf "%s\n" "$PWonce" | sudo -S pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned --noconfirm --needed
wait
#Enable services for Virtmanager
printf "%s\n" "$PWonce" | sudo -S systemctl enable libvirtd.service
wait
printf "%s\n" "$PWonce" | sudo -S systemctl start libvirtd.service
echo "QEMU/KVM Virtmanager has been installed"
wait
#Enable virt manager thing that causes an error after a reboot and you want to start it:
printf "%s\n" "$PWonce" | sudo -S virsh net-autostart default
#Installing VIM (if it's not yet on there already)
printf "%s\n" "$PWonce" | sudo -S pacman -S vim --needed --noconfirm
#VIM Configuration:
mv -i /home/$USER/ArchInstallScript/.vimrc /home/$USER/
#Installing the part that is needed to share clipboard for VM's
#printf "%s\n" "$PWonce" | sudo -S pacman -S spice-vdagent
#End of script
echo -e "${Cyan}Everything has been installed.${Reset}"
sleep 2
echo -e "${Cyan}Exiting script!${Reset}"
sleep 2
