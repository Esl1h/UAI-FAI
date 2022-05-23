#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install curl tilix synaptic yakuake openssh-server \
chromium-browser spyder3 git vim htop most zsh python3-pip fonts-powerline \
git-extras unrar zip unzip p7zip-full p7zip-rar rar openjdk-11-jdk steam fzf

sudo pip3 install tldr setuptools

sudo snap install code --classic

sudo systemctl enable ssh
sudo systemctl start ssh

sudo dd if=/dev/zero of=/swapfile bs=100M count=20
sudo mkswap /swapfile && chmod 600 /swapfile && swapon /swapfile

sudo su - root -c 'cat <<EOT >>/etc/fstab
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
/swapfile    none    swap  sw     0    0
EOT'

sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/sysctl.conf >>/etc/sysctl.conf'

sudo sysctl -p

sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/ssh_config >/etc/ssh/ssh_config'

sudo apt autoremove && sudo apt autoclean && sudo apt clean

# https://www.esli-nux.com/2017/04/ssd-no-linux.html
# https://www.esli-nux.com/2014/08/usar-arquivo-como-memoria-swap.html
# Config files on gists in https://gist.github.com/Esl1h

echo "\n\n\n\n"
echo ################################
read -n 1 -s -r -p "Now, will be install oh-my-zsh - When finished, press CTRL+D to continue , ok? Press any key to continue"

# Install oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# install fonts do ZSH and powerlevel theme
mkdir ~/.fonts
wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v1.2.0/Hack.zip -P ~/.fonts/
cd ~/.fonts/ && unzip Hack.zip

# install some plugins to zsh - syntax high lighting and command auto suggestions
mkdir ~/.oh-my-zsh/completions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# powerlevel9k zsh theme
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# install and config zshrc file:
rm ~/.zshrc
wget -c https://raw.githubusercontent.com/Esl1h/UAI/main/conf/zshrc -O ~/.zshrc
echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc
