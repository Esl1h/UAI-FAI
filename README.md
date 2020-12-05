# UAI

## Ubuntu After Install

Linux Desktop (Ubuntu Based distros) - Script to run after installation

You must:

- change it! Clone and Edit the ssh_config (it's set to my environment)
- run with your common user
- have sudo permission (including 'sudo su')

What this shellscript will do:

- install some apps (using apt and snap!)
- set configurations for sysctl.conf, ssh_config
- install and setup zsh
- install and enable sshd
- configure swapfile and change fstab to logs over tmpfs

### PT-BR

Script para executar após a instalação do Linux Desktop (para distros baseada no Ubuntu).

O que você deve fazer:

- Mudar! Clone e edite o ssh_config (está configurado para o meu ambiente)
- execute com seu usuário
- deve possuir permissão de sudo (inclusive 'sudo su')