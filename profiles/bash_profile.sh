
# Because I always forget:
# The file `.bash_profile` is used loaded for interactive shells.
# So stuff that is only useful at the prompt should go here.

_init() {
	if [[ -z $DEV_TOOLS_ROOT ]]; then
		error_message='
			Error: DEV_TOOLS_ROOT is not set!
			Did you source bashrc.sh correctly?
		'
		echo ${error_message} 1>&2
		# return 2
	fi

	# Custom terminal
	source "$DEV_TOOLS_ROOT/profiles/colors.sh"
	prompt_swap --dynamic

	local os_name=$(uname -o 2>/dev/null || uname -s 2>/dev/null)
	if [[ ${os_name} =~ Msys ]]; then os_win;
	elif [[ ${os_name} =~ Darwin ]]; then os_mac;
	fi

	# Project navigation

	.dev_tools() { enter_project 'dev_tools'; }
	alias '.dev'='.dev_tools'

	register_project 'dev_tools'
	init_project_dev_tools() {
		prefix_prompt '🛠  '
		term-theme DevPurple

		cd "$DEV_TOOLS_ROOT"
		add_to_path "$DEV_TOOLS_ROOT/futility/tests"

		exit_project_dev_tools() { return; }
	}

}

os_win() {
	add_to_path "C:\Program Files\Sublime Text 3"
}

os_mac() {
	##
	# Homebrew bash completions

	## For bash < 4

	# brew_bash_completion() {
	#   if type brew 2&>/dev/null; then
	#   	bash_completion_file=$(brew --prefix)/etc/bash_completion
	#   	if [[ -e $bash_completion_file ]]; then
	#   		source  $bash_completion_file
	#     else
	#       echo_error 'Homebrew bash completions do not exist!'
	#       echo_error 'Homebrew suggests running: brew install git bash-completion'
	#       return $YA_DUN_GOOFED
	#     fi
	#   fi
	#   return 0
	# }

	## For bash >= 4

	brew_bash_completion() {
		export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

		if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
			source "/usr/local/etc/profile.d/bash_completion.sh"
		else
			echo_error 'Homebrew bash completions do not exist!'
		fi
	}

	brew_bash_completion

	#
	##

	# Sublime "subl" CLI

	add_to_path "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
	export EDITOR='subl -n -w'
	alias 'sublime'='subl'

	# Chrome CLI

	add_to_path '/Applications/Google Chrome.app/Contents/MacOS'
	alias 'chrome'='Google\ Chrome'
}

_init
