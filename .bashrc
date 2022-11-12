# ~/.bashrc
#
# This rc file replicates the default bashrc of Gentoo Linux and ensures
# identical colour reproduction on modern terminal emulators. 
# Additionally, git branches are added to PS1.


# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Disable completion when the input buffer is empty.  i.e. Hitting tab
# and waiting a long time for bash to expand all of $PATH.
shopt -s no_empty_cmd_completion

# Enable history appending instead of overwriting when exiting.  #139609
shopt -s histappend

# Save each command to the history file as it's executed.  #517342
# This does mean sessions get interleaved when reading later on, but this
# way the history is always up to date.  History is not synced across live
# sessions though; that is what `history -n` does.
# Disabled by default due to concerns related to system recovery when $HOME
# is under duress, or lives somewhere flaky (like NFS).  Constantly syncing
# the history will halt the shell prompt until it's finished.
#PROMPT_COMMAND='history -a'

# Change the window title of X terminals 
case ${TERM} in
	[aEkx]term*|rxvt*|gnome*|konsole*|interix|tmux*)
		PS1='\[\033]0;\u@\h:\w\007\]'
		;;
	screen*)
		PS1='\[\033k\u@\h:\w\033\\\]'
		;;
	*)
		unset PS1
		;;
esac

# Set colorful PS1 only on colorful terminals.
# dircolors uses the 1;3 value for bold fonts, which the linux
# console interprets as bright colors. However, modern terminal
# emulators use bold fonts and that results in different colors.
# So, we need to hardcode the LS_COLORS using the 9 value instead
# of 1;3 which prints the bright colors in both the linux console
# and modern terminal emulators.
use_color=false
if type -P dircolors >/dev/null ; then
	# Enable colors for ls, etc.
	LS_COLORS='rs=0:di=094:ln=096:mh=00:pi=40;33:so=095:do=095:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=092:*.tar=091:*.tgz=091:*.arc=091:*.arj=091:*.taz=091:*.lha=091:*.lz4=091:*.lzh=091:*.lzma=091:*.tlz=091:*.txz=091:*.tzo=091:*.t7z=091:*.zip=091:*.z=091:*.dz=091:*.gz=091:*.lrz=091:*.lz=091:*.lzo=091:*.xz=091:*.zst=091:*.tzst=091:*.bz2=091:*.bz=091:*.tbz=091:*.tbz2=091:*.tz=091:*.deb=091:*.rpm=091:*.jar=091:*.war=091:*.ear=091:*.sar=091:*.rar=091:*.alz=091:*.ace=091:*.zoo=091:*.cpio=091:*.7z=091:*.rz=091:*.cab=091:*.wim=091:*.swm=091:*.dwm=091:*.esd=091:*.jpg=095:*.jpeg=095:*.mjpg=095:*.mjpeg=095:*.gif=095:*.bmp=095:*.pbm=095:*.pgm=095:*.ppm=095:*.tga=095:*.xbm=095:*.xpm=095:*.tif=095:*.tiff=095:*.png=095:*.svg=095:*.svgz=095:*.mng=095:*.pcx=095:*.mov=095:*.mpg=095:*.mpeg=095:*.m2v=095:*.mkv=095:*.webm=095:*.webp=095:*.ogm=095:*.mp4=095:*.m4v=095:*.mp4v=095:*.vob=095:*.qt=095:*.nuv=095:*.wmv=095:*.asf=095:*.rm=095:*.rmvb=095:*.flc=095:*.avi=095:*.fli=095:*.flv=095:*.gl=095:*.dl=095:*.xcf=095:*.xwd=095:*.yuv=095:*.cgm=095:*.emf=095:*.ogv=095:*.ogx=095:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
	export LS_COLORS
	# Note: We always evaluate the LS_COLORS setting even when it's the
	# default.  If it isn't set, then `ls` will only colorize by default
	# based on file attributes and ignore extensions (even the compiled
	# in defaults of dircolors). #583814
	if [[ -n ${LS_COLORS:+set} ]] ; then
		use_color=true
	else
		# Delete it if it's empty as it's useless in that case.
		unset LS_COLORS
	fi
else
	# Some systems (e.g. BSD & embedded) don't typically come with
	# dircolors so we need to hardcode some terminals in here.
	case ${TERM} in
	[aEkx]term*|rxvt*|gnome*|konsole*|screen|tmux|cons25|*color) use_color=true;;
	esac
fi

if ${use_color} ; then
	if [[ ${EUID} == 0 ]] ; then
		PS1+="\[\033[091m\]\h\[\033[094m\] \w\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/') \\$\[\033[00m\] "
	else
		PS1+="\[\033[092m\]\u@\h\[\033[094m\] \w\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/') \\$\[\033[00m\] "
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
else
	# show root@ when we don't have colors
	PS1+='\u@\h \w \$ '
fi

for sh in /etc/bash/bashrc.d/* ; do
	[[ -r ${sh} ]] && source "${sh}"
done

# Try to keep environment pollution down, EPA loves us.
unset use_color sh

# User specific aliases and functions 
