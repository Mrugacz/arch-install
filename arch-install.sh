cyan='\033[0;36m'
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
separator="\n${cyan}<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>${white}\n"

pacman -Sy figlet --noconfirm
clear
echo -e "$cyan"
figlet arch-installer
echo -e "${white}by mrugacz\n\n\npress enter to continue"
read

timedatectl set-ntp true

echo -e $separator
fdisk -l
echo -e $separator
echo 'Select disk to use. (full path eq. /dev/sda)'
echo -e $separator
read disk
echo -e $separator
echo 'Select how much swap to use. (GiB eq. 8)'
echo -e $separator
read swap
swapend=$((($swap * 1024) + 513 ))

parted -s -a optimal -- $disk \
    mklabel gpt \
    mkpart primary fat32 1MiB 513MiB
bootprt=1
mkfs.fat -F32 $disk$bootprt
if [[ $swap -ne 0 ]]; then
    parted -s -a optimal -- $disk mkpart primary linux-swap 513MiB $swapend
    swapprt=2
    rootprt=3
    mkswap $disk$swapprt
else
    rootprt=2
fi
parted -s -a optimal -- $disk mkpart primary ext4 $swapend -2048s
mkfs.ext4 $disk$rootprt
e2label $disk$rootprt archrfs

mount $disk$rootprt /mnt
mkdir /mnt/boot
mount $disk$bootprt /mnt/boot
if [[ -n $swapprt ]]; then
    swapon $disk$swapprt
fi

echo -e $separator
echo 'Installing base system'
echo -e $separator
pacstrap /mnt base base-devel linux-zen linux-firmware vim networkmanager efibootmgr grub git openssh
genfstab -U /mnt >> /mnt/etc/fstab
cd /mnt
curl https://raw.githubusercontent.com/Mrugacz/arch-install/main/arch-chroot-install.sh > arch-chroot-install.sh
chmod +x arch-chroot-install.sh
arch-chroot /mnt bash arch-chroot-install.sh
