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
prompt_swap --dynamic

##
# Homebrew bash completions

brew_bash_completions() {
  if type brew 2&>/dev/null; then
  	bash_completion_file=$(brew --prefix)/etc/bash_completion
  	if [[ -e $bash_completion_file ]]; then
  		source  $bash_completion_file
    else
      echo_error 'Homebrew bash completions do not exist!'
      echo_error 'Homebrew suggests running: brew install git bash-completion'
      return $YA_DUN_GOOFED
    fi
  fi
  return 0
}

brew_bash_completions

# Sublime "subl" CLI

add_to_path "/Applications/Sublime Text.app/Contents/SharedSupport/bin"

# Project navigation

.dev_tools() { enter_project 'dev_tools'; }
alias '.dev'='.dev_tools'

init_project_dev_tools() {
  prefix_prompt '🛠  '
  term-theme DevPurple

  cd "$DEV_TOOLS_ROOT"
}


