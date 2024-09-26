#!/bin/bash
# https://esli.blog.br/guia-ssd-no-linux
# https://esli.blog.br/ram-e-swap
# Config files on my https://github.com/Esl1h/dotfiles

. /etc/os-release

if [ "${ID}" = "fedora" ]; then
  package_manager="dnf"

elif [ "${ID}" = "ubuntu" ]  || [ "${ID}" = "debian" ] ; then
  package_manager="apt"

else
    echo "(Maybe) your distro is not supported"
    exit

fi


function updated {
    sudo $package_manager update -y
    sudo $package_manager upgrade -y
    sudo $package_manager autoremove -y
}

function install_basics {
    sudo $package_manager install curl flatpak yakuake openssh-server xterm zenity solaar \
                        git vim htop most zsh bat git-extras shellcheck -y
    sudo dconf update
}

function add_flathub {
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

function flatpak_packages {
    flatpak update
    flatpak install flathub \
        com.protonvpn.www \
        org.standardnotes.standardnotes \
        me.timschneeberger.GalaxyBudsClient \
        net.codeindustry.MasterPDFEditor \
        io.github.peazip.PeaZip \
        com.spotify.Client \
        org.telegram.desktop \
        io.github.flattool.Warehouse \
        com.github.tchx84.Flatseal --noninteractive
}

function install_fonts {
  # install fonts to ZSH, Jetbrains and powerlevel theme
      mkdir ~/.fonts
      wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip -P ~/.fonts/ && cd ~/.fonts/ || exit
      unzip Hack.zip
      wget -c https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip -P ~/.local/share/fonts && cd ~/.local/share/fonts || exit
      unzip JetBrainsMono-2.242.zip
      fc-cache -f -v
}


function repos_set {
  # NextDNS
    sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg

 # Softmaker Office
    if [ "${ID}" = "fedora" ]; then
        sudo wget -qO /etc/yum.repos.d/softmaker.repo https://shop.softmaker.com/repo/softmaker.repo
    else
        wget -qO - https://shop.softmaker.com/repo/linux-repo-public.key | sudo apt-key add -
        sudo echo "deb https://shop.softmaker.com/repo/apt stable non-free" | sudo tee  /etc/apt/sources.list.d/softmaker.list
    fi

}

function install_softmaker {
  if [ "${ID}" = "fedora" ]; then
      sudo -E dnf install softmaker-office-nx -y
  else
      sudo apt install softmaker-office-nx -y
fi
}


function install_nextdns {
      sh -c "$(curl -sL https://nextdns.io/install)"
}

function first_run {
  updated
  install_basics
  add_flathub
  flatpak_packages
  install_fonts
}

first_run
repos_set
updated
install_softmaker
install_nextdns



function set_ohmyzsh {
      clear
      read -n 1 -s -r -p "Now, will be install oh-my-zsh - When finished, press CTRL+D to continue , ok? Press any key to continue"

      # Install oh-my-zsh
      sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - && exit)"

      # install some plugins to zsh - syntax high lighting and command auto suggestions
      mkdir -p ~/.oh-my-zsh/completions
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
      git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
      # powerlevel10k zsh theme
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
      rm ~/.zshrc
      wget -c https://raw.githubusercontent.com/Esl1h/dotfiles/main/.zshrc -O ~/.zshrc
      echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
      echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc
}

function sysctl_set {
    sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/sysctl.conf >>/etc/sysctl.conf'
    sudo sysctl -p
}

function ssh_set {
  sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/ssh/ssh_config >/etc/ssh/ssh_config'
  sudo systemctl enable ssh
  sudo systemctl start ssh
}

function dont_need_this {
    sudo su - root -c 'cat <<EOF >>/etc/fstab
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
EOF
'
}

set_ohmyzsh
sysctl_set
ssh_set
dont_need_this



function vim {
  # install VIm-Plug
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  # vimrc from my dotfiles repo
  curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/.vimrc > ~/.vimrc
  #
  read -n 1 -s -r -p "Open vim and run \':PlugInstall! and :PlugUpdate!\', ok? Press any key to continue"
}

vim
