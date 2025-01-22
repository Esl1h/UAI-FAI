
<img align="left" src="https://cdn.hashnode.com/res/hashnode/image/upload/v1714668828239/5bdb9130-09f6-4e44-8f53-d91b18256197.png" height=95 width=90>

![Fedora](https://img.shields.io/badge/Fedora-294172?style=for-the-badge&logo=fedora&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

# UAI-FAI ![Shell](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

"Ubuntu After Install" and "Fedora After Install". Bash script to run after install with my personal sets.

Fun fact: uai-fai is the phonetic form to ````ˈwaɪˌfaɪ```` , a Brasilian English accent way to say wifi.

## Ubuntu or Fedora After Install

Tested since Debian (>10), Ubuntu (>20.04) and Fedora (> 38).
Latest was tested on Debian 12.7, Ubuntu 24.10 and Fedora 41.
Currently I use on laptop with Fedora 40, workstation PC with Ubuntu Studio 24.04 and a Home Server (Intel NUC) with Debian 12.

### Why?
I have three laptops, and I like to:
- have the same environment at all
- In each new distro release, I make a full and cleaned install

So I created this simple script.

You must:

- change it! (it's set to my environment)
- run with your common user
- have sudo permission (including 'sudo su')

What this shellscript will do:

- Update!
- install some apps (yakuake, solaar, git, vim, curl)
- install some my daily apps via flatpak
- install jetbrain fonts and hack fonts.
- set repo and install softmaker office NX
- install NextDNS
- install and setup zsh + oh-my-zsh and powerlevel10k theme
- change fstab to logs over tmpfs
- configs to ssh client (my enviroments on cloud, networks and datacenters)
- configs to sysctl (performance on my home server lab)


## It's a just for fun script

And I am rewritting in Vlang because I have free time ;-)




### PT-BR

Script para executar após a instalação do Linux Desktop (para distros baseada no Ubuntu).

O que você deve fazer:

- Mudar!(está configurado para o meu ambiente)
- execute com seu usuário
- deve possuir permissão de sudo (inclusive 'sudo su')



### Credits

Icon/Logo ["opensource"](https://thenounproject.com/icon/opensource-4957970/) by [M. Oki Orlando](https://thenounproject.com/creator/orvipixel/) from Noun Project (CC BY 3.0)



