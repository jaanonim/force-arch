# bootctl install --esp-path=/boot
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo toor | passwd root --stdin

mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin root --noclear %I $TERM
EOF
systemctl daemon-reload
systemctl enable getty@tty1.service

systemctl enable NetworkManager.service

echo "fastfetch" >>  /etc/profile