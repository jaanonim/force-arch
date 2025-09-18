build: 
    mkarchiso -v -r -w /tmp/archiso-tmp -o ./output ./archlive

remote target:
    ssh root@192.168.56.104 "cd /mnt && just {{target}}"

run:
    ./run_archiso -i output/*.iso

ssh:
    ssh root@192.168.56.104

cache: 
    rm -rf /tmp/pacman-cache
    rm -rf /mnt/archlive/airootfs/root/offline-packages

    mkdir -p /tmp/pacman-cache
    mkdir -p /mnt/archlive/airootfs/root/offline-packages

    pacman --noconfirm --dbpath /tmp/ -Syu -w --cachedir /tmp/pacman-cache base linux linux-firmware grub efibootmgr networkmanager fastfetch
    repo-add /tmp/pacman-cache/custom.db.tar.gz /tmp/pacman-cache/*[^sig]
    
    cp /tmp/pacman-cache/*.pkg.tar.* /mnt/archlive/airootfs/root/offline-packages/
    cp /tmp/pacman-cache/custom.db.tar.gz  /mnt/archlive/airootfs/root/offline-packages/custom.db