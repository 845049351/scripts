# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
	alias antxd="antxexpand $1 ~/program/jboss-6.0.0.Final/server/default/deploy"
	alias jumpold='ssh -qTfnN -D 9999 -p 6200 imbugsco@67.215.236.241'
	alias jumpgea='/home/tinghe/scripts/gae/local/proxy.py'
	alias jumpfree='sshpass -p '47962789' ssh -qTfnN -D 10001 -p 22 free@f1.8ke.in'
	alias jump='ssh -qTfnN -D 9999 imbugsco@r.imbugs.com'
#	alias jump1='ssh -qTfnN -D 9999 -p 22 jslognet@r.jslog.net'
	alias jump1='ssh -qTfnN -D 9999 -p 22 root@alindou.com'
	alias jumpp='ssh -f -N -D 9999 -R 8888:localhost:22 root@17linux.com'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
	alias xstart='vnc4server :1 -geometry 1380x800 -depth 24'
	alias xstop='vnc4server -kill :1'
	alias sssh='/home/tinghe/scripts/sssh/super-ssh.sh'
	alias pd='pushd'
	alias pp='popd'
	alias yzoffice='/usr/local/Yozosoft/Yozo_Office/Yozo_Office.bin'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias su='su -l'
alias cvsst='cvs -q st | grep Status: | grep -v Up-to-date'
alias myps='ps -ef | grep `whoami`'
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias du="du -sh"
alias df="df -h"
alias free="free -m"
alias ps="ps -leaf"
alias less='less --raw-control-chars'
alias mvng='mvn -Dmaven.compiler.encoding=GBK -Dmaven.test.compiler.encoding=GBK -Dproject.build.sourceEncoding=GBK'
alias mvne='mvn clean eclipse:clean eclipse:eclipse'
alias mvnp='mvng clean package -Dmaven.test.skip=true'
alias mvni='mvng clean install -Dmaven.test.skip=true'
alias mvnd='mvng deploy -Dmaven.test.skip=true'
alias mvnc='mvn clean eclipse:clean clean:clean'
alias plantuml='java -jar /opt/software/uml/plantuml.jar'
alias svnup='svn revert --recursive .;svn update --force'
alias dropc='su -c "echo 3 > /proc/sys/vm/drop_caches" root'
alias go='gnome-open'
alias fcp="/home/tinghe/scripts/bin/fcp.sh"
alias ajstat="/home/tinghe/scripts/bin/ajstat.sh"
if [ -f ~/.local_env.sh ]; then
    . ~/.local_env.sh
fi

# Add autojump, jumpstat, j command
if [ -f /usr/share/autojump/autojump.sh ]; then
	. /usr/share/autojump/autojump.sh
fi
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

### chsdir start ###
. $HOME/bin/chs_completion
PATH=$PATH:$HOME/bin
#export CHSDIR="{'n':'l'}"
complete -o filenames -F _filedir_xspec file
### chsdir finish. ###

function cb(){
	cdargs "$1" && cd "`cat "$HOME/.cdargsresult"`"
}

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
