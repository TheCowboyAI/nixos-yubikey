copyenv:
sudo mkdir -p /media/yubikey
sudo mount /dev/sda2 /media/yubikey
cp secrets/.env /media/yubikey
sudo umount /media/yubikey
sudo rmdir -p /media/yubikey