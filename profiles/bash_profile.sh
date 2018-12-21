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
brew_bash_completions() {
  local else="$1"

  if type brew 2&>/dev/null; then
  	bash_completion_file=$(brew --prefix)/etc/bash_completion
  	if [[ -e $bash_completion_file ]]; then
  		source  $bash_completion_file
  	fi	
  elif [[ "$else_log" =~ ^-l|--log$ ]]; then
    echo
  fi 
}
brew_bash_completions

# Sublime "subl" CLI

add_to_path "/Applications/Sublime Text.app/Contents/SharedSupport/bin"