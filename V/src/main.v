module main

import os { read_file, system }

fn main() {

        os_release := read_file('/etc/os-release')  or {
         println('Failed to read /etc/os-release')
         return
        }

        mut id := ''
        for line in os_release.split_into_lines() {
                if line.starts_with('ID=') {
                        id = line.split('=')[1].trim('"')
                        break
                }
        }

        package_manager := match id {
                'fedora' {
                        'dnf'
                }
                'ubuntu', 'debian' {
                        'apt'
                }
                else {
                        println('(Maybe) your distro is not supported')
                        return
                }
        }

        println('Package manager: ${package_manager}')
        if package_manager != '' {
                updated(package_manager)
                install_basics(package_manager)
        } else {
                println('Could not determine the package manager.')
        }

		if os_release.contains('ID=fedora') {
			system('sudo wget -qO /etc/yum.repos.d/softmaker.repo https://shop.softmaker.com/repo/softmaker.repo')
			updated(package_manager)
			system('sudo -E dnf install softmaker-office-nx -y')
		} else {
			system('wget -qO - https://shop.softmaker.com/repo/linux-repo-public.key | sudo apt-key add -')
			system('sudo echo "deb https://shop.softmaker.com/repo/apt stable non-free" | sudo tee /etc/apt/sources.list.d/softmaker.list')
			updated(package_manager)
			system('sudo apt install softmaker-office-nx -y')
		}

	repos_set()
        flathub()
        flatpak_packages()

        fonts_dir := os.home_dir() + '/.fonts'
        if !os.exists(fonts_dir) {
                os.mkdir_all(fonts_dir)! // or {
                // println('Failed to create ~/.fonts directory')
                // return
        }

        hack_fonts := 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip'
        system('wget -c ${hack_fonts} -P ${fonts_dir}') // or {
        // println('Failed to download Hack.zip')
        // return

        os.chdir(fonts_dir)! // or {
        // println('Failed to change directory to ~/.fonts')
        // return

        system('unzip Hack.zip') // or {
        // println('Failed to unzip Hack.zip')
        // return

        local_fonts_dir := os.home_dir() + '/.local/share/fonts'
        if !os.exists(local_fonts_dir) {
                os.mkdir_all(local_fonts_dir)! // or {
                // println('Failed to create ~/.local/share/fonts directory')
                // return
        }

        jetbrains_fonts := 'https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip'
        system('wget -c ${jetbrains_fonts} -P ${local_fonts_dir}') // or {
        // println('Failed to download JetBrainsMono-2.242.zip')
        // return

        os.chdir(local_fonts_dir)! // or {
        // println('Failed to change directory to ~/.local/share/fonts')
        // return

        system('unzip JetBrainsMono-2.242.zip') // or {
        // println('Failed to unzip JetBrainsMono-2.242.zip')
        // return

        system('fc-cache -f -v') // or {
        // println('Failed to refresh font cache')


}



fn updated(package_manager string) {
        system('sudo ${package_manager} update -y')
        system('sudo ${package_manager} upgrade -y')
        system('sudo ${package_manager} autoremove -y')
}

fn install_basics(package_manager string) {
        system('sudo ${package_manager} install curl flatpak yakuake openssh-server xterm zenity solaar git vim htop most zsh bat git-extras -y')
        system('sudo dconf update')
}

fn flathub() {
        system('sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo')
}

fn flatpak_packages() {
        system('flatpak update')
        system('flatpak install flathub com.protonvpn.www org.standardnotes.standardnotes me.timschneeberger.GalaxyBudsClient net.code_industry.MasterPDFEditor io.github.peazip.PeaZip com.spotify.Client org.telegram.desktop io.github.flattool.Warehouse com.github.tchx84.Flatseal --noninteractive')
}

fn repos_set() {
    system('sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg')
	system('sh -c "$(curl -sL https://nextdns.io/install)"')
}



// function set_ohmyzsh {
//       clear
//       read -n 1 -s -r -p "Now, will be install oh-my-zsh - When finished, press CTRL+D to continue , ok? Press any key to continue"

//       # Install oh-my-zsh
//       sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - && exit)"

//       # install some plugins to zsh - syntax high lighting and command auto suggestions
//       mkdir -p ~/.oh-my-zsh/completions
//       git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
//       git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
//       # powerlevel10k zsh theme
//       git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
//       rm ~/.zshrc
//       wget -c https://raw.githubusercontent.com/Esl1h/UAI/main/conf/zshrc -O ~/.zshrc
//       echo export ZSH=\""$HOME"/.oh-my-zsh\" >>~/.zshrc
//       echo "source \$ZSH/oh-my-zsh.sh" >>~/.zshrc
// }

// function sysctl_set {
//     sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/sysctl.conf >>/etc/sysctl.conf'
//     sudo sysctl -p
// }

// function ssh_set {
//   sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/UAI/main/conf/ssh_config >/etc/ssh/ssh_config'
//   sudo systemctl enable ssh
//   sudo systemctl start ssh
// }

// function dont_need_this {
//     sudo su - root -c 'cat <<EOF >>/etc/fstab
// tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
// tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
// tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
// EOF
// '
// }

// set_ohmyzsh
// sysctl_set
// ssh_set
// dont_need_this
