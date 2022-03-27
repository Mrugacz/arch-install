cyan='\033[0;36m'
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
separator="\n${cyan}<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>${white}\n"

ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
echo -e 'en_US.UTF-8 UTF-8\nen_US ISO-8859-1\npl_PL.UTF-8 UTF-8\npl_PL ISO-8859-2' > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo auto-arch > /etc/hostname
mkinitcpio -P

echo -e $separator
echo Enter username for main user
echo -e $separator
read user
useradd -G wheel -m $user
echo -e $separator
echo -e "Enter password for $green$user$white"
echo -e $separator
passwd $user
echo -e 'root ALL=(ALL) ALL\n%wheel ALL=(ALL) ALL\n@includedir /etc/sudoers.d' > /etc/sudoers

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
cpu=$(grep -i vendor /proc/cpuinfo | uniq | awk '{print $3}')
echo -e $separator
echo -e "Downloading CPU microcode for ${green}$cpu${white} CPU"
echo -e $separator
if [[ $cpu == AuthenticAMD ]]; then
    pacman -S amd-ucode --noconfirm
elif [[ $cpu == GenuineIntel ]]; then
    pacman -S intel-ucode --noconfirm
else
    echo -e "${red}Unsupported CPU - no microcode will be downloaded${white}"
fi
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager sshd

su $user -c 'git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg'
pacman -U yay-bin/yay-*.pkg.tar.zst --noconfirm
echo -e $separator
echo -e "${green}Installation complete.${white}\nYou can now reboot your system."
echo -e $separator
