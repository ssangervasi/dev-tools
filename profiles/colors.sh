
export CLICOLOR=1
# export LSCOLORS=GxFxCxDxBxegedabagaced

def_colors() {
	if ! tput setaf &>/dev/null; then
		return $YA_DUN_GOOFED
	fi

	export COLOR_NO_COLOR=$(tput sgr0)
	export COLOR_NC="$COLOR_NO_COLOR"

	c() { tput setaf "$1"; }
	b() { tput bold; }

	export COLOR_BOLD=$(b)
	export COLOR_BLACK=$(c 0)
	export COLOR_BLUE=$(c 4)
	export COLOR_BROWN=$(c 58)
	export COLOR_CYAN=$(c 6)
	export COLOR_GRAY=$(c 7)
	export COLOR_GREY="$COLOR_GRAY"
	export COLOR_GREEN=$(c 2)
	export COLOR_LIGHT_BLUE="$(b)$(c 4)"
	export COLOR_LIGHT_CYAN="$(b)$(c 6)"
	export COLOR_LIGHT_GRAY="$(b)$(c 7)"
	export COLOR_LIGHT_GREY="$COLOR_LIGHT_GRAY"
	export COLOR_LIGHT_GREEN="$(b)$(c 2)"
	export COLOR_LIGHT_PURPLE="$(b)$(c 5)"
	export COLOR_LIGHT_RED="$(b)$(c 1)"
	export COLOR_PURPLE=$(c 5)
	export COLOR_RED=$(c 1)
	export COLOR_WHITE=$(c 7)
	export COLOR_YELLOW=$(c 3)
}

dump_tput_colors() {
	for c in {0..255}; do
		tput setaf $c
		tput setaf $c | cat -v
		echo =$c
	done
}

def_colors

# di = directory
# fi = file
# ln = symbolic link
# pi = fifo file
# so = socket file
# bd = block (buffered) special file
# cd = character (unbuffered) special file
# or = symbolic link pointing to a non-existent file (orphan)
# mi = non-existent file pointed to by a symbolic link (visible when you type ls -l)
# ex = file which is executable (ie. has 'x' set in permissions).
# export LS_COLORS="fi=01;30:"
export LS_COLORS="fi=00;00:di=02;013:ln=0;03:*.horse=02;31:"
# export LS_COLORS="fi=00;13"
# eval $(dircolors <(
# 	cat <<-COLOR_DB
# 		DIR 01;01
# 		DIR 01;01
# 	COLOR_DB
# ))
# export LS_COLORS=$(
# 	cat <<-COLOR_DB | tr '\n' ':' | tr ' ' '='
# 		DIR 01;01
# 	COLOR_DB
# )