 
#!/bin/bash
apt install tilix synaptic yakuake chromium-browser spyder3 git vim htop most zsh python3-pip fonts-powerline git-extras wget 
snap install spotify
sudo snap install --classic code 

systemctl enable ssh
systemctl start ssh

dd if=/dev/zero of=/swapfile bs=100M count=20
mkswap /swapfile && chmod 600 /swapfile && swapon /swapfile

cat <<EOT >> /etc/fstab
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
/swapfile    none    swap  sw     0    0
EOT

curl https://gist.githubusercontent.com/Esl1h/65c0d67780ee6212ebce00efe76d6007/raw/6fbfc331b9a6be1522d3df7f6ea190659893915b/sysctl.conf >> /etc/sysctl.conf

sysctl -p

curl https://gist.githubusercontent.com/Esl1h/29beb6d8af2b16d5438b66180705ad95/raw/7db839086cc92e1f9d073c13adb67026fc75989a/ssh_config > /etc/ssh/ssh_config



# https://www.esli-nux.com/2017/04/ssd-no-linux.html
# https://www.esli-nux.com/2014/08/usar-arquivo-como-memoria-swap.html
# Config files on gists in https://gist.github.com/Esl1h (ssh_config and sysctl.conf)
