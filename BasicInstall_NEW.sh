#!/bin/bash
#
# Make sure this script is run as root
if [[ $EUID -ne 0 ]]; then
    echo
    echo "This script must be run as root" 1>&2
    echo
    exit
fi
wait
#Remove file at the end of script; uncomment to make it work
#rm -- "$0"
#list of variables
#Color variables for error ouput
export Red='\e[38;5;196m'
export Reset='\033[0m'
export Cyan='\e[38;5;87m'
#
intel="GenuineIntel"
AMDCPU="AuthenticAMD"
#Variables for comparisons
export architecture=$(uname -m)
export kernel=$(uname -r | awk {'print substr($0, length($0)-2, 3)'}) #zen or lts
export linuxkernal=$(uname -r | awk {'print substr($0, length($0)-6, 4)'}) #arch
export cpu=$(cat /proc/cpuinfo |grep vendor_id | awk '!seen[$0]++' | awk {'print $3'})
export mygpu=$(lspci -v |grep VGA | awk {'print $5'})
export whichOS=$(cat /etc/*release | grep PRETTY_NAME | cut -d '=' -f2- | tr -d '"' | awk '{print $1}')
#Make a better looking PS1 by replacing .bashrc: (test if this also works on other OS' beside arch)
mv /home/$USER/ArchInstallScript/.bashrc /home/$USER/
wait
#Make .bash_aliases with already some added aliases:
mv /home/$USER/ArchInstallScript/.bash_aliases /home/$USER/
wait
#Disable systemd sleep services
if [[ $(echo $XDG_CURRENT_DESKTOP) == "KDE" ]]; then
    systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
else
    echo -e "You dont have KDE installed but ${Red}${XDG_CURRENT_DESKTOP}${Cyan}"
    sleep 5
fi
wait
#Write the correct settings for Debian OS
#Commenting part that searches on a cdrom instead of searching the internet
debiancd="deb cdrom:[Debian GNU/Linux 12.8.0 _Bookworm_ - Official amd64 DVD Binary-1 with firmware 20241109-11:05]/ bookworm contrib main non-free-firmware"
debianNOcd="#deb cdrom:[Debian GNU/Linux 12.8.0 _Bookworm_ - Official amd64 DVD Binary-1 with firmware 20241109-11:05]/ bookworm contrib main non-free-firmware"
debiannew="s|$debiancd|$debianNOcd|"
if [[ "$whichOS" == "Debian" ]]; then
    sed -i "$debiannew" /etc/apt/sources.list
fi
#Symlink root KDE to User KDE (else we don't see the theme switching, only after logging out/rebooting)
#Change to dark mode
if [[ $(echo $XDG_CURRENT_DESKTOP) == "KDE" ]]; then
    plasma-apply-colorscheme BreezeDark 2> /dev/null && sudo --user=$USER plasma-apply-colorscheme BreezeDark 2> /dev/null
else
    echo -e "You dont have KDE installed but ${Red}${XDG_CURRENT_DESKTOP}${Cyan}"
    sleep 5
wait
#lookandfeeltool -a org.kde.breezedark.desktop --> idk if this is the right way
#First lets do a first time update of our system
if [[ "$whichOS" == "Arch" ]]; then
    pacman -Syu --noconfirm 2> /dev/null
elif [[ "$whichOS" == "Rocky" ]]; then
    sudo dnf update && sudo dnf upgrade
elif [[ "$whichOS" == "Ubuntu" ]]; then
    sudo apt update && sudo apt upgrade
elif [[ "$whichOS" == "Debian" ]]; then
    sudo apt-get update && sudo apt-get upgrade
elif [[ "$whichOS" == "openSUSE" ]]; then
    printf "%s\n" "$PWonce" | sudo -S zypper dup -y
else
    clear
    echo -e "${Red}Cant update system since your OS is not supported by this script!${Cyan}"
    echo -e "${Cyan}You have ${Red}${whichOS}${Cyan}installed."
    echo -e "${Red}Please update manually before continuing this script${Cyan}"
    sleep 10
fi
wait
#Installing right headers for linux/linux-zen
if [[ "$kernel" == "zen" && "$whichOS" = "Arch" ]]; then
    echo "linux-zen kernal detected"
    sleep 2
    pacman -S linux-zen-headers linux-firmware linux-headers --needed --noconfirm
elif [[ "$kernel" == "lts" && "$whichOS" = "Arch" ]]; then
    echo "Linux-lts kernel detected"
    sleep 2
    pacman -S linux-lts-headers linux-headers --needed --noconfirm
elif [[ "$linuxkernal" == "arch" && "$whichOS" = "Arch" ]]; then
    echo "default linux kernel detected"
    sleep 2
    pacman -S linux-headers linux-firmware --needed --noconfirm
else
    echo -e "${Red}You don't have linux, linux-lts or linux-zen kernel installed on your system!${Reset}"
    echo -e "${Cyan}You use kernel: ${Red}${kernel}${Cyan} & OS: ${Red}${whichOS}${Cyan}"
    echo -e "${Red}No kernal headers will be installed! Script will continue in 5s${Reset}"
    sleep 5
fi
wait
#Installing intel-ucode for intel machines
if [[ "$cpu" == "$intel" ]] && [[ "$whichOS" == "Arch" ]]; then
    pacman -S intel-ucode --needed --noconfirm
elif [[ "$cpu" == "$AMDCPU" ]] && [[ "$whichOS" == "Arch" ]]; then
    pacman -S amd-ucode --needed --noconfirm
elif [[ "$cpu" == "$intel" ]] && [[ "$whichOS" == "Debian" ]]; then
    sudo apt-get install intel-microcode
elif [[ "$cpu" == "$AMDCPU" ]] && [[ "$whichOS" == "Debian" ]]; then
    sudo apt-get install amd64-microcode
elif [[ "$cpu" == "$intel" ]] && [[ "$whichOS" == "Ubuntu" ]]; then
    sudo apt install intel-microcode
elif [[ "$cpu" == "$AMDCPU" ]] && [[ "$whichOS" == "Ubuntu" ]]; then
    sudo apt install amd64-microcode
elif [[ "$cpu" == "$intel" ]] && [[ "$whichOS" == "Rocky" ]]; then
    sudo yum install microcode_ctl
elif [[ "$cpu" == "$AMDCPU" ]] && [[ "$whichOS" == "Rocky" ]]; then
    sudo yum install microcode_ctl
else
    echo -e "${Red}Error: You don't have an Intel or AMD CPU!${Reset}"
    echo -e "${Red}Error: OR no Arch Linux or Debian!${Reset}"
    echo -e "${Red}No ucode (microcode) will be installed${Reset}"
    echo -e "${Red}Skipping to next step in 3s${Reset}"
    sleep 3
fi
wait
#Installing the right video card drivers
if [[ "$kernel" == "zen" && "$mygpu" == "NVIDIA" ]]; then
    echo "linux-zen & Nvidia detected; will install nvidia-dkms"
    sleep 2
    pacman -S nvidia-dkms --needed --noconfirm
elif [[ "$kernel" == "lts" ]] && "$mygpu" == "NVIDIA" ]]; then
    echo "linux-lts & Nvidia detected; will install nvidia-lts"
    sleep 2
    pacman -S nvidia-lts --needed --noconfirm
elif [[ "$linuxkernel" == "arch" ]] && "$mygpu" == "NVIDIA" ]]; then
    echo "default linux kernel & Nvidia detected; will install nvidia"
    sleep 2
    pacman -S nvidia --needed --noconfirm
else
    echo -e "${Red}You have something else installed. Either another distro or another brand videocard!${Cyan}"
    echo -e "${Cyan}Your distro is ${Red}${whichOS}${Cyan} & your gpu is ${Red}${mygpu}${Cyan}"
    echo -e "${Red}Will do nothing & continue script!${Cyan}"
fi
wait
#Check if /etc/pacman.d/hooks/ directory exists; if not adding hooks map
if [ -d "/etc/pacman.d/hooks/" ]; then
    echo -e "${Cyan}Directory already exists!${Reset}"
elif [[ "$whichOS" == "Arch" ]] && [[ "$kernel" != "zen" ]] && [ ! -d "/etc/pacman.d/hooks/" ]; then
    mkdir "/etc/pacman.d/hooks"
    wait
    cp /home/$USER/ArchInstallScript/nvidia.hook /etc/pacman.d/hooks/
    echo -e "${Cyan}Directory was made & nvidia.hook has been added!"
else
    echo -e "${Cyan}You are not using Arch but ${Red}${whichOS}${Cyan}. Skipping this part..."
fi
wait
#Check what settings needs to be overwritten based on kernel + gpu hook
old_path="#HookDir     = /etc/pacman.d/hooks/"
new_path="HookDir     = /etc/pacman.d/hooks/"
sed_hook="s|$old_path|$new_path|"
if [[ "$kernel" == "zen" && "$mygpu" == "NVIDIA" && "$whichOS" == "Arch" ]]; then
    echo -e "${Cyan}Hooks are not needed for DKMS versions; will already go automaticly${Reset}"
elif [[ "$kernel" == "lts" ]] && "$mygpu" == "NVIDIA" && "$whichOS" == "Arch" ]]; then
    sed -i 's/Target=nvidia-dkms/Target=nvidia-lts/' /etc/pacman.d/hooks/nvidia.hook
    sed -i 's/Target=linux-zen/Target=linux-lts/' /etc/pacman.d/hooks/nvidia.hook
    sed -i "$sed_hook" /etc/pacman.conf
    echo -e "${Cyan}Config has been rewritten for linux-lts & nvidia-lts${Reset}"
    sleep 2
elif [[ "$linuxkernel" == "arch" ]] && [[ "$mygpu" == "NVIDIA" && "$whichOS" == "Arch" ]]; then
    sed -i 's/Target=nvidia-dkms/Target=nvidia/' /etc/pacman.d/hooks/nvidia.hook
    sed -i 's/Target=linux-zen/Target=linux/' /etc/pacman.d/hooks/nvidia.hook
    sed -i "$sed_hook" /etc/pacman.conf
    echo -e "${Cyan}Config has been rewritten for linux default kernal and default nvidia drivers${Reset}"
else
    echo -e "${Red}You don't have zen, lts, default linux kernel OR you are not using Arch.${Cyan}"
    echo -e "${Cyan}You are using: ${Red}${whichOS}${Cyan} with kernel: ${Red}${kernel}${Cyan}"
    echo -e "${Red}Skipping this step!${Cyan}"
    sleep 10
fi
wait
#Editing GRUB config for Intel+Nvidia
if [[ "$cpu" == "$intel" ]] && [[ "$mygpu" == "NVIDIA" && "$whichOS" == "Arch" ]]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log=priority=3 nvidia_drm.modeset=1 nvidia-drm.fbdev=1 ibt=off"/' /etc/default/grub
    echo -e "${Cyan}lines have been added to /etc/default/grub${Reset}"
elif
    [[ "$cpu" == "$intel" ]] && [[ "$mygpu" == "NVIDIA" && "$whichOS" == "Rocky" ]]; then
    echo >> /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log=priority=3 nvidia_drm.modeset=1 nvidia-drm.fbdev=1 ibt=off"
    echo -e "${Cyan}lines have been added to /etc/default/grub${Reset}"
elif
    [[ "$cpu" == "$intel" ]] && [[ "$mygpu" == "NVIDIA" && "$whichOS" == "Ubuntu" ]]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log=priority=3 nvidia_drm.modeset=1 nvidia-drm.fbdev=1 ibt=off"/' /etc/default/grub
    echo -e "${Cyan}lines have been added to /etc/default/grub${Reset}"
elif
    [[ "$cpu" == "$intel" ]] && [[ "$mygpu" == "NVIDIA" && "$whichOS" == "Debian" ]]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log=priority=3 nvidia_drm.modeset=1 nvidia-drm.fbdev=1 ibt=off"/' /etc/default/grub
    echo -e "${Cyan}lines have been added to /etc/default/grub${Reset}"
fi
wait
#Adding user to video group
echo -e "Adding current user: ${Red}${USER}${Cyan} to video group"
usermod -aG video $USER
wait
#for Debian we wont get added to sudo group by default:
if [[ "$whichOS" == "Debian" ]]; then
    sudo usermod -aG sudo $USER
fi
#Write settings to GRUB & mkinitcpio at the end of the script for ARCH
if [[ "$whichOS" == "Arch" ]]; then
    grub-mkconfig -o /boot/grub/grub.cfg && mkinitcpio -P 2> /dev/null
    echo -e "${Cyan}All settings have been written to the configs.${Reset}"
    echo -e "${Red}Please reboot your system${Reset}"
    sleep 10
    wait
elif [[ "$whichOS" != "Arch" ]]; then
    grub-mkconfig -o /boot/grub/grub.cfg 2> /dev/null
    echo -e "${Cyan}All settings have been written to the configs.${Reset}"
    echo -e "${Red}Please reboot your system${Reset}"
    sleep 10
    wait
else
    echo -e "${Red}Error!!!!!${Cyan}"
fi
