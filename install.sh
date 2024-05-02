#!/bin/bash
# https://esli.blog.br/guia-ssd-no-linux
# https://esli.blog.br/ram-e-swap
# Config files on gists in https://gist.github.com/Esl1h

. /etc/os-release

if [ "${ID}" = "fedora" ]; then
  package_manager="dnf"

elif [ "${ID}" = "ubuntu" ] ; then
  package_manager="apt"

else
    echo "(maybe) your distro not suported"
    exit

fi


function updated {
    sudo $package_manager update -y
    sudo $package_manager upgrade -y
    sudo $package_manager autoremove -y
}

function install_basics {
    sudo $package_manager install curl flatpak yakuake openssh-server xterm zenity solaar \
                        git vim htop most zsh bat git-extras -y
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

function first_run {
  updated
  install_basics
  add_flathub
  flatpak_packages
  install_fonts
}

first_run


function repos_set {
  # NextDNS
    sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg

 # Softmaker Office
    if [ "${ID}" = "fedora" ]; then
        sudo wget -qO /etc/yum.repos.d/softmaker.repo https://shop.softmaker.com/repo/softmaker.repo
    else
        wget -qO - https://shop.softmaker.com/repo/linux-repo-public.key | sudo apt-key add -
    fi

}

function install_softmaker {
  if [ "${ID}" = "fedora" ]; then
      sudo -E dnf install softmaker-office-nx -y

else
      sudo echo "deb https://shop.softmaker.com/repo/apt stable non-free" | sudo tee  /etc/apt/sources.list.d/softmaker.list
      updated
      sudo apt install softmaker-office-nx

fi
}


function install_nextdns {
      sh -c "$(curl -sL https://nextdns.io/install)"
}

repos_set
updated
install_softmaker
install_nextdns



function set_ohmyzsh {
      printf "\n\n\n\n"
      read -n 1 -s -r -p "Now, will be install oh-my-zsh - When finished, press CTRL+D to continue , ok? Press any key to continue"

      # Install oh-my-zsh
      sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - && exit)"

      # install some plugins to zsh - syntax high lighting and command auto suggestions
      mkdir -p ~/.oh-my-zsh/completions
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
      git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
      rm ~/.zshrc
      wget -c https://raw.githubusercontent.com/Esl1h/UAI/main/conf/zshrc -O ~/.zshrc
      echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
      echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc

}


set_ohmyzsh



# function dont_need_this {
#     sudo su - root -c 'cat <<EOT >>/etc/fstab
# tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
# tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
# tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
# }

# function sysctl_set {
#     sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/sysctl.conf >>/etc/sysctl.conf'
#     sudo sysctl -p
# }

# function ssh_set {
#   sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/ssh_config >/etc/ssh/ssh_config'
#   sudo systemctl enable ssh
#   sudo systemctl start ssh
# }
