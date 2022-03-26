timedatectl set-ntp true

fdisk -l
echo disk
read disk
echo swap
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

pacstrap /mnt base base-devel linux-zen linux-firmware vim networkmanager efibootmgr grub git
genfstab -U /mnt >> /mnt/etc/fstab
mv arch-chroot-install.sh /mnt/
arch-chroot /mnt
