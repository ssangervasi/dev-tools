#!/bin/bash

# The file `.bashrc` is used loaded for non-interactive shells.
# So anything I might call from a subshell should go here.

if [[ -z $DEV_HOME ]]; then
	echo 'Error: DEV_HOME is not set!' 1>&2
	exit 92
elif [[ ! -d $DEV_HOME ]]; then
	echo 'Error: DEV_HOME does not exist!' 1>&2
	exit 92
fi

if [[ -z $DEV_TOOLS_ROOT ]]; then
	DEV_TOOLS_ROOT="$(dirname $BASH_SOURCE)/.."
fi
if [[ ! -d $DEV_TOOLS_ROOT ]]; then
	echo 'Error: DEV_TOOLS_ROOT does not exist !' 1>&2
	exit 92
fi

# My tools
source "$DEV_TOOLS_ROOT/futility/core.sh"

# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_HOME/projects
source /usr/local/bin/virtualenvwrapper.sh 2> /dev/null

# Go
export GOROOT="$DEV_HOME/go"
add_to_path "/usr/local/go/bin" "/b/Go/bin"

# Rust Cargo -- should be in bashrc.sh?
add_to_path "$HOME/.cargo/bin"

##
# These things are slow to source, so on-demand aliases
# 	speed up the creation of new shells a lot.
##

# Ruby Env
rbenv_lazy() {
	if empty $(which rbenv); then
		echo_error "You ain't got no rbenv"
		return $YA_DUN_GOOFED
	fi
	echo "Using rbenv"
	unalias 'rbenv'
	eval "$(rbenv init -)"
	return 0
}
alias rbenv='rbenv_lazy; rbenv'

rvm_lazy() {
	if empty $(which rvm); then
		echo_error "You ain't got no rvm"
		return $YA_DUN_GOOFED
	fi
	echo "Using rvm"
	unalias 'rvm'
	export PATH="$PATH:$HOME/.rvm/bin"
	if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
		source "$HOME/.rvm/scripts/rvm"
	fi
	return 0
}
alias rvm='rvm_lazy; rvm'

bundle_lazy() {
	(rvm_lazy || rbenv_lazy) && unalias bundle
}
alias bundle='bundle_lazy && bundle'

nvm_lazy() {
	unalias nvm
	export NVM_DIR="$HOME/.nvm"
	# This loads nvm
	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		source "$NVM_DIR/nvm.sh"
	fi
	# This loads nvm bash_completion
	if [[ -s "$NVM_DIR/bash_completion" ]]; then
		source "$NVM_DIR/bash_completion"
	fi
}
alias nvm='nvm_lazy; nvm'

##
# It is necessary to load these utilities after the lazy definitions
# 	because they need bundle, etc. to be in scope.
##

source "$DEV_TOOLS_ROOT/futility/package.sh"
source "$DEV_TOOLS_ROOT/profiles/aliases.sh"
