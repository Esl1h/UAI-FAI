module main

import os { read_file, system }

fn main() {
	os_release := read_file('/etc/os-release') or {
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
			'apt-get'
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

	nextdns()
	flathub()
	flatpak_packages()
	brave()
	install_fonts()
	set_ohmyzsh()
	sysctl_set()
	ssh_set()
	dont_need_this()
	set_vim()
}

fn run_command(command string) {
	result := os.execute(command)
	if result.exit_code != 0 {
		println('Error running command: ${command}')
		println('Output: ${result.output}')
	}
}

fn updated(package_manager string) {
	system('sudo ${package_manager} update -qq -y && sudo ${package_manager} upgrade -qq -y')
	system('sudo ${package_manager} autoremove -qq -y')
}

fn install_basics(package_manager string) {
	system('sudo ${package_manager} install curl flatpak yakuake openssh-server xterm zenity solaar git vim htop most zsh bat git-extras -y')
	system('sudo dconf update')
}

fn flathub() {
	system('sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo')
}

fn flatpak_packages() {
	system('flatpak update --appstream -y && flatpak remote-ls flathub > /dev/null')
	system('flatpak install flathub com.protonvpn.www org.standardnotes.standardnotes me.timschneeberger.GalaxyBudsClient net.code_industry.MasterPDFEditor io.github.peazip.PeaZip com.spotify.Client org.telegram.desktop io.github.flattool.Warehouse com.github.tchx84.Flatseal --noninteractive')
}

fn nextdns() {
	system('sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg')
	system('sh -c "$(curl -sL https://nextdns.io/install)"')
}

fn brave() {
	system('sh -c "$(curl -sL https://dl.brave.com/install.sh)"')
}

fn install_fonts() {
	local_fonts_dir := os.home_dir() + '/.local/share/fonts'
	if !os.exists(local_fonts_dir) {
		os.mkdir_all(local_fonts_dir) or {
			println('Failed to create ~/.local/share/fonts directory')
			return
		}
	}

	os.chdir(local_fonts_dir) or {
		println('Failed to change directory to ~/.local/share/fonts')
		return
	}

	hack_fonts := 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip'
	jetbrains_fonts := 'https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip'

	system('wget -c ${hack_fonts} -P ${local_fonts_dir}')
	system('wget -c ${jetbrains_fonts} -P ${local_fonts_dir}')

	system('unzip Hack.zip')
	system('unzip JetBrainsMono-2.242.zip')
	system('fc-cache -f -v')
}

fn set_ohmyzsh() {
	home := os.getenv('HOME')

	if home == '' {
		eprintln('Failed to get HOME environment variable')
		return
	}

	system('clear')
	println('Now, will be installed oh-my-zsh - When finished, press CTRL+D to continue, ok? Press any key to continue...')
	// os.input()

	// Install oh-my-zsh
	run_command('sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - && exit)"')

	// Install some plugins to zsh - syntax highlighting and command auto-suggestions
	run_command('mkdir -p ~/.oh-my-zsh/completions')
	run_command('git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && sleep 2')
	run_command('git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && sleep 2')

	// Powerlevel10k zsh theme
	run_command('git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && sleep 2')
	run_command('rm ~/.zshrc')
	run_command('wget -c https://raw.githubusercontent.com/Esl1h/dotfiles/main/.zshrc -O ~/.zshrc')

	// Lê o conteúdo atual do arquivo
	current_content := os.read_file('${home}/.zshrc') or {
		eprintln('Failed to read ~/.zshrc')
		return
	}

	// Adiciona as novas linhas ao conteúdo existente
	new_content := current_content + "\nexport ZSH=\"${home}/.oh-my-zsh\"\nsource \$ZSH/oh-my-zsh.sh\n"

	// Escreve todo o conteúdo de volta ao arquivo
	os.write_file('${home}/.zshrc', new_content) or {
		eprintln('Failed to update ~/.zshrc')
		return
	}
}

fn sysctl_set() {
	run_command("sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/sysctl.conf >>/etc/sysctl.conf'")
	run_command('sudo sysctl -p')
}

fn ssh_set() {
	run_command("sudo su - root -c 'curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/etc/ssh/ssh_config >/etc/ssh/ssh_config' && sleep 2")
	run_command('sudo systemctl enable sshd')
	run_command('sudo systemctl start sshd')
}

fn dont_need_this() {
	fstab_content := '\ntmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0\ntmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0\ntmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0\n'

	run_command("sudo su - root -c 'echo \"${fstab_content}\" >> /etc/fstab'")
}

fn set_vim() {
	run_command('mkdir -p ~/.vim/autoload')
	run_command('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && sleep 2')
	run_command('curl https://raw.githubusercontent.com/Esl1h/dotfiles/main/.vimrc > ~/.vimrc && sleep 2')
	println('Open vim to install and update plugins, ok? Press Enter to continue...')
	// os.input()
}
