#!/bin/bash
# https://esli.blog.br/uai-fai
# Config files on my https://github.com/Esl1h/dotfiles

. /etc/os-release

LOGFILE="uai-fai-install.log"
exec > >(sudo tee -i $LOGFILE) 2>&1

DRY_RUN=0
if [ "$1" == "--dry-run" ]; then
    echo "Running in dry run mode. No actual changes will be made."
    DRY_RUN=1
fi

function run_command {
    if [ $DRY_RUN -eq 1 ]; then
        echo "[DRY RUN] $@"
    else
        eval "$@"
    fi
}

# Error handling function
function error_exit {
    echo "$1" >&2
    exit 1
}

function set_package_manager {
  if [ "${ID}" = "fedora" ]; then
    package_manager="dnf"

  elif [ "${ID}" = "ubuntu" ]  || [ "${ID}" = "debian" ] ; then
    package_manager="apt"

  else
      echo "(Maybe) your distro is not supported"
      exit 1

  fi
}

function update_system {
    run_command "sudo $package_manager update -y" || error_exit "Failed to update system"
    run_command "sudo $package_manager upgrade -y" || error_exit "Failed to upgrade system"
    run_command "sudo $package_manager autoremove -y" || error_exit "Failed to autoremove packages"
}


function install_apps {
    echo "Installing common software packages..."
    common_apps=(curl flatpak yakuake openssh-server xterm zenity solaar git vim htop most zsh bat git-extras shellcheck wget kleopatra)

    for app in "${common_apps[@]}"; do
        if ! command -v "$app" &> /dev/null; then
            run_command "sudo $package_manager install $app -y" || error_exit "Failed to install $app"
        else
            echo "$app is already installed."
        fi
    done

    if [ "${ID}" = "fedora" ]; then
        run_command "sudo $package_manager install wireguard-tools -y"
    else
        run_command "sudo $package_manager install wireguard -y"
    fi
}



function add_flathub {
    run_command "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" || error_exit "Failed to add flathub"
    }


function flatpak_packages {
    run_command "flatpak update -y" || error_exit "Failed to update flatpak"
    run_command "flatpak install flathub \
        com.protonvpn.www \
        org.standardnotes.standardnotes \
        me.timschneeberger.GalaxyBudsClient \
        net.code_industry.MasterPDFEditor \
        io.github.peazip.PeaZip \
        com.spotify.Client \
        org.telegram.desktop \
        org.torproject.torbrowser-launcher \
        org.onionshare.OnionShare \
        io.github.flattool.Warehouse \
        com.github.tchx84.Flatseal --noninteractive" || error_exit "Failed to install flatpak/flathub packages"
}

function download_fonts {
    run_command "mkdir -p $HOME/.local/share/fonts"
    echo "Downloading Hack font..."
    run_command "wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip -P $HOME/.local/share/fonts/"

    echo "Downloading JetBrainsMono font..."
    run_command "wget -c https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip -P $HOME/.local/share/fonts/"
    echo "Font downloads completed."
}

function install_fonts {
    run_command "unzip -o $HOME/.local/share/fonts/Hack.zip -d $HOME/.local/share/fonts/" || error_exit "Failed to unzip Hack font"
    run_command "unzip -o $HOME/.local/share/fonts/JetBrainsMono-2.304.zip -d $HOME/.local/share/fonts/" || error_exit "Failed to unzip JetBrainsMono font"
    run_command "fc-cache -f -v" || error_exit "Failed to refresh font cache"
}


function repos_set {
  # NextDNS
    run_command "sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg" || error_exit "Failed to install nextdns"

 # Softmaker Office and Brave Browser
    if [ "${ID}" = "fedora" ]; then
        run_command "sudo wget -qO /etc/yum.repos.d/softmaker.repo https://shop.softmaker.com/repo/softmaker.repo"
        run_command "sudo $package_manager install dnf-plugins-core -y"

        if [ $VERSION_ID -le 40 ]; then
            # Fedora =< 40
            run_command "sudo $package_manager config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
            else
                # Fedora >= 41
                run_command "sudo wget -qO brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
                sed -i '/autorefresh/s/^/#/' brave-browser.repo
                run_command "sudo $package_manager config-manager addrepo --from-repofile=brave-browser.repo"
            fi
        run_command "sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"

    else
        run_command "wget -qO - https://shop.softmaker.com/repo/linux-repo-public.key | sudo apt-key add -"
        run_command "sudo echo "deb https://shop.softmaker.com/repo/apt stable non-free" | sudo tee  /etc/apt/sources.list.d/softmaker.list"
        run_command "sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"| sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    fi

}

function install_newapps {
  update_system
  run_command "sudo $package_manager install brave-browser softmaker-office-nx -y"
}

function install_nextdns {
      run_command "sudo curl -sL https://nextdns.io/install > ~/nextdns-install.sh && chmod +x ~/nextdns-install.sh"
      run_command "sudo ~/nextdns-install.sh install"
}

# Install Zsh and Oh-My-Zsh
function install_zsh {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        read -n 1 -s -r -p "After install ohmyzsh, press CTRL + D to continue, ok? Now press any key..."
        run_command "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"" || error_exit "Failed to install oh-my-zsh"
    fi
}

function set_ohmyzsh {
      # install some plugins to zsh - syntax high lighting and command auto suggestions
      run_command "mkdir -p ~/.oh-my-zsh/completions"
      run_command "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
      run_command "git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
      # powerlevel10k zsh theme
      run_command "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k"
      run_command "rm ~/.zshrc"
      run_command "wget -c https://raw.githubusercontent.com/Esl1h/dotfiles/main/.zshrc -O ~/.zshrc"
      echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
      echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc
}

function sysctl_set {
    run_command "sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/sysctl.conf >>/etc/sysctl.conf' "
    run_command "sudo sysctl -p"
}

function ssh_set {
  run_command "sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/ssh/ssh_config >/etc/ssh/ssh_config' "
  run_command "sudo systemctl enable sshd"
  run_command "sudo systemctl start sshd"
}

function dont_need_this {
    sudo su - root -c 'cat <<EOF >>/etc/fstab
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
EOF
'
}

function set_vim {
  run_command "mkdir -p ~/.vim/autoload"
  # install VIm-Plug
  run_command "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  # vimrc from my dotfiles repo
  run_command "curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/.vimrc > ~/.vimrc"
  #
  read -n 1 -s -r -p "Open vim to install and update plugins, ok? Press any key to continue"
}



main() {
  set_package_manager
  update_system
  install_apps
  add_flathub
  flatpak_packages
  download_fonts
  install_fonts
  # run_command "sudo dconf update" || error_exit "Failed to update dconf" #gnome only?
  repos_set
  update_system
  install_newapps
  install_nextdns
  install_zsh
  set_ohmyzsh
  sysctl_set
  ssh_set
  dont_need_this
  set_vim
}

main
