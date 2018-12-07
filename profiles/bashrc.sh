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

##
# My tools
##

source "$DEV_TOOLS_ROOT/futility/package.sh"
source "$DEV_TOOLS_ROOT/profiles/aliases.sh"

# General Use

add_to_path "$HOME/bin"

# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_HOME/projects
source /usr/local/bin/virtualenvwrapper.sh 2> /dev/null

# Go
export GOROOT="$DEV_HOME/go"
add_to_path "/usr/local/go/bin" "/b/Go/bin"

# Rust Cargo -- should be in bashrc.sh?
add_to_path "$HOME/.cargo/bin"

# Haskell Stack Binaries
add_to_path "$HOME/.local/bin"

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
	if [[ $(type -t rbenv) != 'function' ]]; then
		return 0
	fi
	unset rbenv
	unalias 'rbenv' 2> /dev/null
	eval "$(rbenv init -)"
	echo "Using rbenv:" $(which rbenv)
	return 0
}

rbenv() {
	rbenv_lazy && rbenv
}

rvm_lazy() {
	local rvm_dir="$HOME/.rvm"
	if [[ ! -s "$rvm_dir/scripts/rvm" ]]; then
		echo_error "You ain't got no rvm"
		return $YA_DUN_GOOFED
	fi
	if [[ $(type -t rvm) != 'function' ]]; then
		return 0
	fi
	unset rvm
	export PATH="$PATH:$rvm_dir/bin"
	source "$HOME/.rvm/scripts/rvm"
	echo "Using rvm:" $(which rvm)
	return 0
}

rvm() {
	rvm_lazy && rvm $@;
}

bundle_lazy() {
	if [[ $(type -t bundle) != 'function' ]]; then
		return 0
	fi
	unset bundle
	rvm_lazy || rbenv_lazy
	if [[ $? > 0 ]]; then
		echo_error 'Could find ruby environment for bundler'
		return $YA_DUN_GOOFED
	fi
	echo 'Using bundler:' $(which bundler)
	return 0
}

bundle() {
	bundle_lazy && bundle $@
}

nvm_lazy() {
	export NVM_DIR="$HOME/.nvm"
	unalias 'nvm' 2> /dev/null
	# This loads nvm
	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		source "$NVM_DIR/nvm.sh"
	fi
	# This loads nvm bash_completion
	if [[ -s "$NVM_DIR/bash_completion" ]]; then
		source "$NVM_DIR/bash_completion"
	fi
}
alias nvm='nvm_lazy && nvm'
