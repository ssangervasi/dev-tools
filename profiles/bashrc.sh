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
source "$DEV_TOOLS_ROOT/futility/package.sh"
source "$DEV_TOOLS_ROOT/profiles/aliases.sh"

# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_HOME/projects
source /usr/local/bin/virtualenvwrapper.sh 2> /dev/null

# Go
export GOROOT="$DEV_HOME/go"
add_to_path "/usr/local/go/bin" "/b/Go/bin"
