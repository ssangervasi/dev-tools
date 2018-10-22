#!/bin/bash

# Because I always forget:
# The file `.bash_profile` is used loaded for interactive shells.
# So stuff that is only useful at the prompt should go here.

if [[ -z $DEV_TOOLS_ROOT ]]; then
	error_message='
		Error: DEV_TOOLS_ROOT is not set!
		Did you source bashrc.sh correctly?
	'
	echo $error_message 1>&2
fi

# Custom terminal
source "$DEV_TOOLS_ROOT/profiles/colors.sh"
prompt_swap --info

# Homebrew bash completions
if type brew 2&>/dev/null; then
	source $(brew --prefix)/etc/bash_completion
fi

# Rust Cargo -- should be in bashrc.sh?
add_to_path "$HOME/.cargo/bin"

# Ruby Env
rbenv_lazy() {
	if ! empty $(which rbenv); then
		eval "$(rbenv init -)"
	fi
}
alias rbenv='unalias rbenv; rbenv_lazy; rbenv '
