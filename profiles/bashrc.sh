
# The file `.bashrc` is used loaded for non-login shells.
# So anything I might call from a subshell should go here.

_init() {
	if [[ -z $DEV_TOOLS_ROOT ]]; then
		DEV_TOOLS_ROOT="$(dirname $BASH_SOURCE)/.."
	fi

	##
	# My tools
	##

	source "$DEV_TOOLS_ROOT/futility/package.sh"
	source "$DEV_TOOLS_ROOT/profiles/aliases.sh"


	if [[ -z $DEV_HOME ]]; then
		export DEV_HOME=~/dev_home
	fi

	if [[ ! -d $DEV_HOME ]]; then
		echo_error 'Error: DEV_HOME does not exist! Expected: '"$DEV_HOME"
		return ${YA_DUN_GOOFED}
	fi

	if [[ -z $WORKSPACE ]]; then
		export WORKSPACE=~/workspace
	fi


	##
	# Bash history
	##

	# Number of lines to keep in the history file
	export HISTSIZE=1000000
	# bash history is timestamped as YYYY-MM-DD HH:MM:SS
	export c='%F %T '
	# Don't put duplicate lines or lines beinning with a space in the history.
	export HISTCONTROL=ignoreboth
	# Unify history across shells
	shopt -s histappend

	# General Use

	add_to_path "$HOME/bin"
	add_to_path "$HOME/.local/bin"
}

_init
