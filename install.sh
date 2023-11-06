#!/bin/bash
# https://esli.blog.br/guia-ssd-no-linux
# https://esli.blog.br/ram-e-swap
# Config files on gists in https://gist.github.com/Esl1h

function updated {
    sudo apt update
    sudo apt upgrade -y
    sudo snap refresh
    sudo apt autoremove -y
    sudo apt autoclean -y
    sudo apt clean -y
}

function install_basics {
  sudo apt install  curl tilix yakuake openssh-server xterm zenity solaar \
                    git vim htop most zsh python3-pip fonts-powerline libutempter0 bat \
                    git-extras openjdk-18-jdk fzf flatpak apt-transport-https gnome-software-plugin-flatpak -y
  sudo snap install lsd
  pip3 install tldr setuptools
  sudo apt install dconf-cli
  sudo dconf update
}

function swapfile_set {
    sudo dd if=/dev/zero of=/swapfile bs=100M count=40 && sudo mkswap /swapfile
    sudo chmod 600 /swapfile
    sudo swapon /swapfile
}

function dont_need_this {
    sudo su - root -c 'cat <<EOT >>/etc/fstab
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
/swapfile    none    swap  sw     0    0'
}

function sysctl_set {
    sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/sysctl.conf >>/etc/sysctl.conf'
    sudo sysctl -p
}

function ssh_set {
  sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/ssh_config >/etc/ssh/ssh_config'
  sudo systemctl enable ssh
  sudo systemctl start ssh
}

function install_fonts {
  # install fonts to ZSH, Jetbrains and powerlevel theme
  mkdir ~/.fonts
  wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip -P ~/.fonts/ && cd ~/.fonts/
  unzip Hack.zip
  wget -c https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip -P ~/.local/share/fonts && cd ~/.local/share/fonts
  unzip JetBrainsMono-2.242.zip
  fc-cache -f -v
}

function repos_set {
  # Softmaker Office
  wget -qO - https://shop.softmaker.com/repo/linux-repo-public.key | sudo apt-key add - && \
  sudo echo "deb https://shop.softmaker.com/repo/apt stable non-free" | sudo tee  /etc/apt/sources.list.d/softmaker.list
  # Flathub
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  # NextDNS
  sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg
  echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list

}

function first_run {
  updated
  install_basics
  swapfile_set
  dont_need_this
  sysctl_set
  ssh_set
  install_fonts
  repos_set
}

function second_install {
  sudo apt install nextdns
  sudo apt install softmaker-office-nx -y
}

function flatpak_packages {
  flatpak update
  flatpak install flathub \
    com.visualstudio.code \
    com.protonvpn.www \
    com.jetbrains.IntelliJ-IDEA-Community \
    com.jetbrains.PyCharm-Community \
    net.cozic.joplin_desktop \
    me.timschneeberger.GalaxyBudsClient \
    com.brave.Browser \
    org.mozilla.firefox \
    net.codeindustry.MasterPDFEditor \
    io.github.peazip.PeaZip \
    network.loki.Session \
    com.valvesoftware.Steam \
    com.spotify.Client \
    org.telegram.desktop \
    dev.bsnes.bsnes \
    io.github.flattool.Warehouse \
    com.github.tchx84.Flatseal --noninteractive

}

function nextdns_set {
  sudo nextdns install -config <your config id> -report-client-info -auto-activate
}

first_run
updated
#nextdns_set CHANGE CONFIG ID!
second_install
flatpak_packages

function install_zsh_ohmyzsh {
      printf "\n\n\n\n"
      echo ################################
      read -n 1 -s -r -p "Now, will be install oh-my-zsh - When finished, press CTRL+D to continue , ok? Press any key to continue"

      # Install oh-my-zsh
      sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

      # install some plugins to zsh - syntax high lighting and command auto suggestions
      mkdir -p ~/.oh-my-zsh/completions
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
      git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
      git clone --depth 1 https://github.com/junegunn/fzf.git             ~/.fzf
      ~/.fzf/install

      # powerlevel10k zsh theme
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
}

function config_zsh_ohmyzsh {
    # config zshrc file:
    rm ~/.zshrc
    wget -c https://raw.githubusercontent.com/Esl1h/UAI/main/conf/zshrc -O ~/.zshrc
    echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
    echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc

    wget -c https://raw.githubusercontent.com/Esl1h/UAI/main/conf/p10k.zsh -O ~/.p10k.zsh
}

install_zsh_ohmyzsh
config_zsh_ohmyzsh