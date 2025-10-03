#!/bin/bash
# Usage: ./install.sh /dev/sdX

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Error: Run as root"
    exit 1
fi

echo "Available drives:"
fdisk -l
echo "================"

# Check if drive is provided as argument
if [ -n "$1" ]; then
    DRIVE="$1"
else
    # Auto-detect drive
    DRIVE=$(lsblk -dno NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}' | grep -E 'nvme|mmcblk' | head -1)
    if [ -z "$DRIVE" ]; then
        DRIVE=$(lsblk -dno NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}' | head -1)
    fi
fi

if [ ! -b "$DRIVE" ]; then
    echo "Error: $DRIVE is not a block device"
    exit 1
fi

echo "Installing on $DRIVE... (in 5s)"
sleep 5
echo "Formatting $DRIVE..."

# Unmount existing partitions
umount ${DRIVE}* 2>/dev/null || true

# Wipe partition table
wipefs -af "$DRIVE"

# Create GPT partition table
parted -sf "$DRIVE" mklabel gpt

# Create partitions
parted -sf "$DRIVE" mkpart "EFI" fat32 1MiB 513MiB
parted -sf "$DRIVE" set 1 esp on
parted -sf "$DRIVE" mkpart "swap" linux-swap 513MiB 8705MiB
parted -sf "$DRIVE" mkpart "root" ext4 8705MiB 100%

# Wait for kernel
partprobe "$DRIVE"
sleep 2


# Determine partition names
if [[ "$DRIVE" =~ nvme|mmcblk ]]; then
    BOOT="${DRIVE}p1"
    SWAP="${DRIVE}p2"
    ROOT="${DRIVE}p3"
else
    BOOT="${DRIVE}1"
    SWAP="${DRIVE}2"
    ROOT="${DRIVE}3"
fi

echo FORMAT

# Format partitions
echo fat:
mkfs.fat -F32 "$BOOT"
echo swap:
mkswap -q "$SWAP"
echo ext4:
mkfs.ext4 -q -F "$ROOT"


echo "Done! Partitions created:"
echo "  Boot (EFI): $BOOT"
echo "  Swap: $SWAP" 
echo "  Root: $ROOT"
echo ""

echo "Mounting partitions:"
mount $ROOT /mnt
mount --mkdir $BOOT /mnt/boot
swapon $SWAP
echo "Done!"

echo "Pacmap keygen:"
pacman-key --init
pacman-key --populate
echo "Done"


echo "Install:"
pacstrap -K /mnt base linux linux-firmware grub efibootmgr networkmanager fastfetch
echo "Done!"

echo "Setup fstub:"
genfstab -U /mnt >> /mnt/etc/fstab
echo "Done"

echo "Chroot:"
cat /root/post_install.sh | arch-chroot /mnt
echo "Done"

shutdown -h now