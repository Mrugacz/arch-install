ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
echo -e 'en_US.UTF-8 UTF-8\nen_US ISO-8859-1\npl_PL.UTF-8 UTF-8\npl_PL ISO-8859-2' > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo auto-arch > /etc/hostname
mkinitcpio -P

echo user
read user
useradd -G wheel -m $user
passwd $user
echo -e 'root ALL=(ALL) ALL\n%wheel ALL=(ALL) ALL\n@includedir /etc/sudoers.d' > /etc/sudoers

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
echo 'cpu vendor'
read cpu
if [[ ${$cpu,} == amd ]]; then
    pacman -S amd-ucode
elif [[ ${$cpu,} == intel ]]; then
    pacman -S intel-ucode
else
    echo 'unsupported cpu - no ucode will be downloaded'
fi
grub-mkconfig -o /boot/grub/grub.cfg

su $user
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
echo '----------------'
echo "|    done'd    |"
echo '----------------'
